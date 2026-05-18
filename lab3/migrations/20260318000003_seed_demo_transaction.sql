-- +goose Up
-- Демо-транзакция нужна, чтобы страница React "Транзакции" не была пустой после первого запуска Docker.
-- Важно: вставка сделана через SELECT по существующим демо-карте и демо-терминалу,
-- чтобы миграция не падала на старом Docker volume из-за FOREIGN KEY constraint failed.
INSERT INTO transactions (amount, card_id, terminal_id)
SELECT 65.0, c.id, t.id
FROM cards c
JOIN terminals t ON t.serial_number = 'TERM-TEST-01'
WHERE c.card_number = '1234567890123456'
  AND NOT EXISTS (
    SELECT 1
    FROM transactions tr
    WHERE tr.amount = 65.0
      AND tr.card_id = c.id
      AND tr.terminal_id = t.id
  );

-- +goose Down
DELETE FROM transactions
WHERE amount = 65.0
  AND card_id IN (SELECT id FROM cards WHERE card_number = '1234567890123456')
  AND terminal_id IN (SELECT id FROM terminals WHERE serial_number = 'TERM-TEST-01');
