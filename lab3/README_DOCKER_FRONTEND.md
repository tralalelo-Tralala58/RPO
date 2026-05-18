# Payment Auth Server + React frontend

Проект запускается полностью через Docker.

## Адреса

- Frontend: https://localhost:8888/
- API: https://localhost:8888/api/v1
- Swagger: https://localhost:8888/api/v1/swagger

## Запуск

```bash
docker compose down -v
docker compose build --no-cache
docker compose up
```

## Тестовые пользователи

Администратор:

```text
admin
admin123
```

Обычный пользователь можно создать через страницу `Пользователи`, зайти под ним и проверить ограничения.

## Роли

Frontend читает роль пользователя из JWT payload. Если `is_admin=true`, в меню показывается `Payment Auth Admin`. Если `is_admin=false`, показывается `Payment Auth User`.

Обычный пользователь может просматривать данные, но при попытке выполнить административное действие получает уведомление о недостатке прав.

На backend дополнительно защищены административные действия middleware `AdminOnly`, включая операции терминала `/terminal/authorize` и `/terminal/keys`.
