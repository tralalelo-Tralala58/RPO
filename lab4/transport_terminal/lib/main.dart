import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:pn532_cli/pn532_cli.dart';

void main() {
  runApp(const TransportTerminalApp());
}

class TransportTerminalApp extends StatelessWidget {
  const TransportTerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Terminal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PaymentPage(),
    );
  }
}

class LibNfcScanResult {
  const LibNfcScanResult({
    required this.found,
    this.uidHex,
    this.uidCompactHex,
    this.atqaHex,
    this.sakHex,
    this.message,
    this.error,
  });

  final bool found;
  final String? uidHex;
  final String? uidCompactHex;
  final String? atqaHex;
  final String? sakHex;
  final String? message;
  final String? error;

  factory LibNfcScanResult.fromMap(Map<dynamic, dynamic> map) {
    return LibNfcScanResult(
      found: map['found'] == true,
      uidHex: map['uidHex'] as String?,
      uidCompactHex: map['uidCompactHex'] as String?,
      atqaHex: map['atqaHex'] as String?,
      sakHex: map['sakHex'] as String?,
      message: map['message'] as String?,
      error: map['error'] as String?,
    );
  }
}

void libNfcScanIsolateEntry(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final connstring = args[1] as String;
  final timeoutSeconds = args[2] as int;

  final reader = LibNfcReader(connstring: connstring);
  final stopwatch = Stopwatch()..start();

  try {
    reader.open();

    while (stopwatch.elapsed < Duration(seconds: timeoutSeconds)) {
      final card = reader.scanOneCard();

      if (card != null) {
        sendPort.send({
          'found': true,
          'uidHex': card.uidHex,
          'uidCompactHex': card.uidCompactHex,
          'atqaHex': card.atqaHex,
          'sakHex': card.sakHex,
        });
        return;
      }

      sleep(const Duration(milliseconds: 200));
    }

    sendPort.send({
      'found': false,
      'message': 'Card not found before timeout.',
    });
  } catch (e) {
    sendPort.send({'found': false, 'error': e.toString()});
  } finally {
    try {
      reader.close();
    } catch (_) {
      // Ignore close errors.
    }
  }
}

Future<LibNfcScanResult> runLibNfcScanInIsolate({
  required String connstring,
  required int timeoutSeconds,
}) async {
  final receivePort = ReceivePort();

  await Isolate.spawn(libNfcScanIsolateEntry, [
    receivePort.sendPort,
    connstring,
    timeoutSeconds,
  ]);

  final message = await receivePort.first;
  receivePort.close();

  if (message is Map) {
    return LibNfcScanResult.fromMap(message);
  }

  return LibNfcScanResult(
    found: false,
    error: 'Unexpected isolate response: $message',
  );
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final apiBaseController = TextEditingController(
    text: 'https://localhost:8888/api/v1',
  );

  final terminalController = TextEditingController(text: 'TERM-001');
  final cardController = TextEditingController(text: 'b754105e');
  final amountController = TextEditingController(text: '65');

  final ownerNameController = TextEditingController(text: 'Test Passenger');
  final initialBalanceController = TextEditingController(text: '500');
  final keyIdController = TextEditingController(text: '1');

  final connstringController = TextEditingController(
    text: 'pn532_uart:/dev/tty.usbserial-TGJLH5CH',
  );

  bool loadingPayment = false;
  bool loadingCreateCard = false;
  bool scanning = false;
  bool isBlocked = false;

  String paymentResultText = '';
  String createCardResultText = '';
  String scanResultText = '';

  bool? approved;

  late final IOClient client;

  @override
  void initState() {
    super.initState();

    final httpClient = HttpClient()
      ..badCertificateCallback = (certificate, host, port) {
        return host == 'localhost' || host == '127.0.0.1';
      };

    client = IOClient(httpClient);
  }

  @override
  void dispose() {
    apiBaseController.dispose();
    terminalController.dispose();
    cardController.dispose();
    amountController.dispose();
    ownerNameController.dispose();
    initialBalanceController.dispose();
    keyIdController.dispose();
    connstringController.dispose();
    client.close();
    super.dispose();
  }

  Future<void> scanCard() async {
    setState(() {
      scanning = true;
      scanResultText = 'Opening libnfc reader...\nWaiting for card...';
      approved = null;
    });

    try {
      final connstring = connstringController.text.trim();

      if (connstring.isEmpty) {
        throw Exception('libnfc connstring is required');
      }

      final result = await runLibNfcScanInIsolate(
        connstring: connstring,
        timeoutSeconds: 10,
      );

      if (!mounted) {
        return;
      }

      if (result.error != null) {
        setState(() {
          scanResultText = 'Scan error: ${result.error}';
        });
        return;
      }

      if (!result.found) {
        setState(() {
          scanResultText =
              '''
Card not found.

Timeout: 10 seconds
${result.message ?? ''}
''';
        });
        return;
      }

      final uidCompact = result.uidCompactHex;

      if (uidCompact == null || uidCompact.isEmpty) {
        throw Exception('libnfc returned empty UID compact');
      }

      setState(() {
        cardController.text = uidCompact;
        scanResultText =
            '''
Card found via libnfc.

UID: ${result.uidHex}
UID compact: ${result.uidCompactHex}
ATQA: ${result.atqaHex}
SAK: ${result.sakHex}
''';
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        scanResultText = 'Scan error: $e';
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        scanning = false;
      });
    }
  }

  Future<void> createCard() async {
    setState(() {
      loadingCreateCard = true;
      createCardResultText = '';
    });

    try {
      final apiBase = trimRightSlash(apiBaseController.text.trim());
      final cardNumber = cardController.text.trim().toLowerCase();
      final ownerName = ownerNameController.text.trim();
      final initialBalance = int.tryParse(initialBalanceController.text.trim());
      final keyId = int.tryParse(keyIdController.text.trim());

      if (apiBase.isEmpty) {
        throw Exception('API base URL is required');
      }

      if (cardNumber.isEmpty) {
        throw Exception('Card UID is required. Scan card first.');
      }

      if (ownerName.isEmpty) {
        throw Exception('Owner name is required');
      }

      if (initialBalance == null || initialBalance < 0) {
        throw Exception('Initial balance must be zero or positive integer');
      }

      if (keyId == null || keyId <= 0) {
        throw Exception('Key ID must be positive integer');
      }

      final token = await login(apiBase);

      final response = await client.post(
        Uri.parse('$apiBase/cards'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode({
          'card_number': cardNumber,
          'owner_name': ownerName,
          'balance': initialBalance,
          'is_blocked': isBlocked,
          'key_id': keyId,
        }),
      );

      final body = response.body;

      if (response.statusCode == 409) {
        setState(() {
          createCardResultText =
              'Card already exists.\n\nBackend response:\n$body';
        });
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: $body');
      }

      final json = jsonDecode(body) as Map<String, dynamic>;

      setState(() {
        createCardResultText =
            'Card created successfully:\n\n${const JsonEncoder.withIndent('  ').convert(json)}';
      });
    } catch (e) {
      setState(() {
        createCardResultText = 'Create card error: $e';
      });
    } finally {
      setState(() {
        loadingCreateCard = false;
      });
    }
  }

  Future<void> authorizePayment() async {
    setState(() {
      loadingPayment = true;
      paymentResultText = '';
      approved = null;
    });

    try {
      final apiBase = trimRightSlash(apiBaseController.text.trim());
      final terminalSerial = terminalController.text.trim();
      final cardNumber = cardController.text.trim().toLowerCase();
      final amount = int.tryParse(amountController.text.trim());

      if (apiBase.isEmpty) {
        throw Exception('API base URL is required');
      }

      if (terminalSerial.isEmpty) {
        throw Exception('Terminal serial is required');
      }

      if (cardNumber.isEmpty) {
        throw Exception('Card UID is required');
      }

      if (amount == null || amount <= 0) {
        throw Exception('Amount must be a positive integer');
      }

      final token = await login(apiBase);

      final response = await client.post(
        Uri.parse('$apiBase/terminal/transactions/authorize'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode({
          'terminal_serial': terminalSerial,
          'card_number': cardNumber,
          'amount': amount,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      setState(() {
        approved = json['approved'] == true;
        paymentResultText = const JsonEncoder.withIndent('  ').convert(json);
      });
    } catch (e) {
      setState(() {
        approved = false;
        paymentResultText = 'Error: $e';
      });
    } finally {
      setState(() {
        loadingPayment = false;
      });
    }
  }

  Future<String> login(String apiBase) async {
    final response = await client.post(
      Uri.parse('$apiBase/auth/login'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode({'username': 'admin', 'password': 'admin123'}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Login failed: HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final token = json['token'];

    if (token is! String || token.isEmpty) {
      throw Exception('Login response does not contain token');
    }

    return token;
  }

  String trimRightSlash(String value) {
    var result = value;
    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = approved == true
        ? Colors.green
        : approved == false
        ? Colors.red
        : Colors.grey;

    final statusText = approved == true
        ? 'APPROVED'
        : approved == false
        ? 'DECLINED / ERROR'
        : 'READY';

    return Scaffold(
      appBar: AppBar(title: const Text('Transport Terminal')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'PN532 card scanner via libnfc',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: connstringController,
                        decoration: const InputDecoration(
                          labelText: 'libnfc connstring',
                          helperText:
                              'Example: pn532_uart:/dev/tty.usbserial-TGJLH5CH',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: scanning ? null : scanCard,
                        child: scanning
                            ? const Text('Scanning via libnfc...')
                            : const Text('Scan card via libnfc'),
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        scanResultText.isEmpty
                            ? 'No scan yet.'
                            : scanResultText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Register scanned card',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: cardController,
                        decoration: const InputDecoration(
                          labelText: 'Card UID compact',
                          helperText: 'Filled automatically after libnfc scan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: ownerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Owner name',
                          helperText: 'Any passenger name or label',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: initialBalanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Initial balance',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: keyIdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'MIFARE key ID',
                          helperText: 'Default demo key is usually 1',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Blocked card'),
                        subtitle: const Text('Usually disabled for new cards'),
                        value: isBlocked,
                        onChanged: (value) {
                          setState(() {
                            isBlocked = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: loadingCreateCard ? null : createCard,
                        child: loadingCreateCard
                            ? const Text('Adding card...')
                            : const Text('Add scanned card'),
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        createCardResultText.isEmpty
                            ? 'No card registration yet.'
                            : createCardResultText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Payment authorization',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: apiBaseController,
                        decoration: const InputDecoration(
                          labelText: 'API base URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: terminalController,
                        decoration: const InputDecoration(
                          labelText: 'Terminal serial',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Payment amount',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: loadingPayment ? null : authorizePayment,
                        child: loadingPayment
                            ? const Text('Processing...')
                            : const Text('Authorize payment'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        paymentResultText.isEmpty
                            ? 'No payment yet.'
                            : paymentResultText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
