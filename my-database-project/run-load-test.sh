#!/bin/bash

# Скрипт для запуску load testing
# Використання: ./run-load-test.sh [URL] [USERS] [DURATION]

set -e

# Параметри за замовчуванням
TARGET_URL=${1:-"http://localhost:8080"}
USERS=${2:-20}
DURATION=${3:-120}
RAMP_UP=${4:-20}

echo "🚀 Starting Load Test"
echo "Target URL: $TARGET_URL"
echo "Users: $USERS"
echo "Duration: ${DURATION}s"
echo "Ramp-up: ${RAMP_UP}s"
echo ""

# Перевіряємо чи доступний сервіс
echo "🔍 Checking if service is available..."
if ! curl -s -f "$TARGET_URL/api/authors" > /dev/null; then
    echo "❌ Service is not available at $TARGET_URL"
    echo "Make sure the service is running and accessible"
    exit 1
fi
echo "✅ Service is available"

# Запускаємо load test
echo "🏃 Running load test..."
python3 load-test.py \
    --url "$TARGET_URL" \
    --users "$USERS" \
    --duration "$DURATION" \
    --ramp-up "$RAMP_UP"

echo "✅ Load test completed"
