package ru.iu3.fclient;

import androidx.appcompat.app.AppCompatActivity;

import org.apache.commons.codec.DecoderException;
import org.apache.commons.codec.binary.Hex;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;

import org.apache.commons.codec.binary.Hex;

import ru.iu3.fclient.databinding.ActivityMainBinding;

public class MainActivity extends AppCompatActivity implements TransactionEvents{
    private ActivityResultLauncher<Intent> activityResultLauncher;

    // Used to load the 'fclient' library on application startup.
    static {
        System.loadLibrary("fclient");
        System.loadLibrary("mbedcrypto");
    }

    private ActivityMainBinding binding;

    private void testEncryption() {
        // Ключ для 3DES: ровно 16 байт (2-key 3DES)
        byte[] key = "MySecretKey12345".getBytes(); // 16 символов = 16 байт

        // Исходные данные
        String originalText = "Hello, IoT!";
        byte[] data = originalText.getBytes();

        Log.d("fclient_test", "Original: " + originalText);

        // Шифруем
        byte[] encrypted = encrypt(key, data);
        Log.d("fclient_test", "Encrypted length: " + encrypted.length);
        Log.d("fclient_test", "Encrypted (hex): " + bytesToHex(encrypted));

        // Дешифруем
        byte[] decrypted = decrypt(key, encrypted);
        String result = new String(decrypted);
        Log.d("fclient_test", "Decrypted: " + result);

        // Проверка
        if (originalText.equals(result)) {
            Log.d("fclient_test", "✅ TEST PASSED");
        } else {
            Log.e("fclient_test", "❌ TEST FAILED");
        }
    }

    // Вспомогательный метод для вывода байтов в hex
    private String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02X", b));
        }
        return sb.toString();
    }

    public static byte[] stringToHex(String s) {
        byte[] hex;
        try {
            hex = Hex.decodeHex(s.toCharArray());
        } catch (DecoderException ex) {
            ex.printStackTrace();
            hex = new byte[0];  // возвращаем пустой массив вместо null
        }
        return hex;
    }

    public void onButtonClick(View v)
    {
        /*byte[] key = stringToHex("0123456789ABCDEF0123456789ABCDE0");
        byte[] enc = encrypt(key, stringToHex("000000000000000102"));
        byte[] dec = decrypt(key, enc);
        String s = new String(Hex.encodeHex(dec)).toUpperCase();
        Toast.makeText(this, s, Toast.LENGTH_SHORT).show();*/

        //Intent it = new Intent(this, PinpadActivity.class);

        //startActivity(it);
        //activityResultLauncher.launch(it);

        new Thread(()-> {
            try {
                byte[] trd = stringToHex("9F0206000000000100");
                transaction(trd);

            } catch (Exception ex) {
                // todo: log error
            }
        }).start();
    }

    @Override
    public void transactionResult(boolean result) {
        runOnUiThread(()-> {
            Toast.makeText(MainActivity.this, result ? "ok" : "failed", Toast.LENGTH_SHORT).show();
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        int res = initRng();
        byte[] v = randomBytes(10);

        TextView tv = findViewById(R.id.sample_text);
        tv.setText(stringFromJNI());

        testEncryption();

        activityResultLauncher  = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                new ActivityResultCallback<ActivityResult> () {
                    @Override
                    public void onActivityResult(ActivityResult result) {
                        if (result.getResultCode() == Activity.RESULT_OK) {
                            Intent data = result.getData();

                            // обработка результата
                            //String pin = data.getStringExtra("pin");
                            //Toast.makeText(MainActivity.this, pin, Toast.LENGTH_SHORT).show();

                            pin = data.getStringExtra("pin");
                            synchronized (MainActivity.this) {
                                MainActivity.this.notifyAll();
                            }
                        }
                    }
                });

        // Example of a call to a native method
    }

    /**
     * A native method that is implemented by the 'fclient' native library,
     * which is packaged with this application.
     * ndk - 29.0.14206865
     * cmake - 4.1.2
     */
    public native String stringFromJNI();
    public static native int initRng();
    public static native byte[] randomBytes(int no);

    public static native byte[] decrypt(byte[] key, byte[] data);

    public static native byte[] encrypt(byte[] key, byte[] data);

    public native boolean transaction(byte[] trd);

    private String pin;
    @Override
    public String enterPin(int ptc, String amount) {
        pin = new String();
        Intent it = new Intent(MainActivity.this, PinpadActivity.class);
        it.putExtra("ptc", ptc);
        it.putExtra("amount", amount);
        synchronized (MainActivity.this) {
            activityResultLauncher.launch(it);
            try {
                MainActivity.this.wait();
            } catch (Exception ex) {
                //todo: log error
            }
        }
        return pin;
    }
}