-- +goose Up
-- Демо-данные нужны, чтобы после чистого docker compose up сразу можно было войти и проверить frontend/API.
-- Логин: admin
-- Пароль: admin123
INSERT OR IGNORE INTO users (id, login, name, password_hash, is_admin)
VALUES (1, 'admin', 'Admin User', '$2a$10$soTK15RjCcrFvXpbQORlr.l5mbFTgUua/2aAs1EekJ0a6yL3H4sm2', 1);

INSERT OR IGNORE INTO terminals (id, serial_number, address, name)
VALUES (1, 'TERM-TEST-01', 'Baymanskaya D1', 'T_Bmn');

INSERT OR IGNORE INTO keys (id, key_value, description)
VALUES (1, 'A1B2C3D4E5F6', 'MIFARE Classic Key B');

INSERT OR IGNORE INTO cards (id, card_number, balance, is_locked, owner_name, key_id)
VALUES (1, '1234567890123456', 850.0, 0, 'Ivan Ivanov', 1);

-- +goose Down
DELETE FROM transactions WHERE card_id = 1 OR terminal_id = 1;
DELETE FROM cards WHERE id = 1;
DELETE FROM keys WHERE id = 1;
DELETE FROM terminals WHERE id = 1;
DELETE FROM users WHERE id = 1 AND login = 'admin';
