# ========================
# Stage 1: Сборка React frontend
# ========================
FROM node:20-alpine AS frontend-builder

WORKDIR /frontend

# Сначала копируем только package-файлы, чтобы Docker кэшировал npm-зависимости
COPY frontend/package.json ./
RUN npm config set registry https://registry.npmjs.org/ \
    && npm install --no-audit --no-fund

# Копируем исходники frontend и собираем production-версию
COPY frontend ./
RUN npm run build


# ========================
# Stage 2: Сборка Go backend
# ========================
FROM golang:1.25-alpine AS backend-builder

# gcc/musl-dev нужны для github.com/mattn/go-sqlite3 через CGO
RUN apk add --no-cache gcc musl-dev

WORKDIR /app

# Копируем модули отдельно для кэширования зависимостей
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код backend
COPY cmd ./cmd
COPY internal ./internal
COPY docs ./docs
COPY migrations ./migrations

# Собираем backend-бинарник
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o server ./cmd/server


# ========================
# Stage 3: Финальный образ: Go backend + Nginx + React static
# ========================
FROM alpine:latest

RUN apk --no-cache add ca-certificates nginx openssl sqlite

RUN mkdir -p /app/certs /app/data /usr/share/nginx/html /var/log/nginx /run/nginx

# Backend
COPY --from=backend-builder /app/server /app/server
COPY --from=backend-builder /app/migrations /app/migrations

# Frontend: Vite build лежит в /frontend/dist
COPY --from=frontend-builder /frontend/dist /usr/share/nginx/html

# Nginx config
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Entrypoint: запускает backend, ждёт готовности и затем запускает nginx
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Самоподписанный SSL-сертификат для лабораторной работы
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /app/certs/key.pem \
    -out /app/certs/cert.pem \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=Lab2/CN=localhost"

EXPOSE 8888

# В одном контейнере запускаются backend на 127.0.0.1:8080 и nginx на https://localhost:8888
CMD ["/app/docker-entrypoint.sh"]
