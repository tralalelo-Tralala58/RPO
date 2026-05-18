#!/bin/sh
set -e

echo "Starting Go backend..."
/app/server &
BACKEND_PID=$!

# Ждём backend, чтобы nginx не начал сразу отдавать 502 при первом обращении.
# Если backend упал из-за ошибки миграции/БД, контейнер остановится и покажет ошибку в docker logs.
for i in $(seq 1 30); do
  if wget -q -O /dev/null http://127.0.0.1:8080/api/v1/health 2>/dev/null; then
    echo "Backend is ready. Starting nginx..."
    exec nginx -g 'daemon off;'
  fi

  if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
    echo "Backend process exited before nginx startup. Check logs above."
    wait "$BACKEND_PID"
    exit 1
  fi

  sleep 1
done

echo "Backend did not become ready in time. Check docker logs."
exit 1
