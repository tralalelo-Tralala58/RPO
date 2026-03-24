# ========================
# Stage 1: Сборка Go-бинарника
# ========================
FROM golang:1.25-alpine AS builder

# Устанавливаем зависимости для CGO (нужен для sqlite3)
RUN apk add --no-cache gcc musl-dev

WORKDIR /app

# Копируем модули (для кэширования)
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код
COPY . .

# Собираем бинарник
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o server ./cmd/server


# ========================
# Stage 2: Финальный образ с Nginx
# ========================
FROM alpine:latest

# Устанавливаем: ca-certificates, nginx, openssl
RUN apk --no-cache add ca-certificates nginx openssl sqlite

# Создаём директории
RUN mkdir -p /app/certs /app/data /usr/share/nginx/html /var/log/nginx

# Копируем бинарник из builder
COPY --from=builder /app/server /app/server

COPY --from=builder /app/migrations /app/migrations

# Копируем конфиг Nginx
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Генерируем самоподписанный SSL-сертификат (для dev)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /app/certs/key.pem \
    -out /app/certs/cert.pem \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=Lab2/CN=localhost"

# Открываем порт 8888 для HTTPS
EXPOSE 8888

# Запускаем Go-сервер + Nginx
CMD ["sh", "-c", "/app/server & nginx -g 'daemon off;'"]