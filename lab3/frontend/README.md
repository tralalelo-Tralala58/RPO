# React frontend для payment-auth-server

Этот frontend сделан под твой backend на Go из лабораторной работы: JWT-логин, CRUD для users / terminals / cards / keys, просмотр transactions и отдельная страница для terminal API.

## Что уже есть

- React + TypeScript + Vite
- JWT авторизация через `/api/v1/auth/login`
- protected routes
- единый API client
- страницы:
  - `/users`
  - `/terminals`
  - `/cards`
  - `/keys`
  - `/transactions`
  - `/terminal-tools`

## Как запустить локально

```bash
npm install
npm run dev
```

По умолчанию Vite проксирует `/api` на `https://localhost:8888`, поэтому backend должен быть поднят в Docker.

## Переменные окружения

Создай `.env` по примеру `.env.example`:

```env
VITE_API_BASE_URL=https://localhost:8888/api/v1
```

## Что ещё стоит доделать

1. Роли по JWT на фронте, чтобы скрывать admin-only кнопки.
2. Нормальную обработку 401 и автоматический logout.
3. Пагинацию и фильтрацию таблиц.
4. Формы через react-hook-form + yup/zod.
5. Отдельную страницу Swagger с iframe или ссылкой.
6. Сборку `dist` и раздачу через Nginx из того же Docker-образа.

## Как встроить в твой текущий Docker образ

1. Собираешь frontend: `npm run build`
2. Копируешь папку `dist` в Nginx image
3. Настраиваешь Nginx так, чтобы:
   - `/api/v1/` проксировался в Go backend
   - `/` отдавал React `index.html`

Пример блока для Nginx:

```nginx
location /api/v1/ {
    proxy_pass http://127.0.0.1:8080/api/v1/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location / {
    root /usr/share/nginx/html;
    try_files $uri $uri/ /index.html;
}
```

## Важно

Сейчас frontend сделан под фактические endpoints проекта из архива. Если ты потом поменяешь DTO или маршруты в Go-сервере, надо будет синхронизировать `src/types` и `src/api/services.ts`.
