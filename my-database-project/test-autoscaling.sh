#!/bin/bash

# Комплексний скрипт для тестування автоматичного масштабування
# Використання: ./test-autoscaling.sh [target-url] [test-duration]

set -e

TARGET_URL=${1:-"http://localhost:8080"}
TEST_DURATION=${2:-180}  # 3 хвилини за замовчуванням
MONITOR_DURATION=$((TEST_DURATION + 60))  # +1 хвилина для моніторингу

echo "🧪 Starting Autoscaling Test"
echo "Target URL: $TARGET_URL"
echo "Test Duration: ${TEST_DURATION}s"
echo "Monitor Duration: ${MONITOR_DURATION}s"
echo ""

# Перевіряємо чи доступний сервіс
echo "🔍 Checking service availability..."
if ! curl -s -f "$TARGET_URL/api/authors" > /dev/null; then
    echo "❌ Service is not available at $TARGET_URL"
    echo "Make sure the service is running and accessible"
    exit 1
fi
echo "✅ Service is available"

# Запускаємо моніторинг в фоновому режимі
echo "📊 Starting monitoring in background..."
./monitor-scaling.sh $MONITOR_DURATION &
MONITOR_PID=$!

# Чекаємо 10 секунд для ініціалізації моніторингу
sleep 10

# Запускаємо load test
echo "🏃 Starting load test..."
python3 load-test.py \
    --url "$TARGET_URL" \
    --users 30 \
    --duration $TEST_DURATION \
    --ramp-up 30 &

LOAD_TEST_PID=$!

# Чекаємо завершення load test
wait $LOAD_TEST_PID
echo "✅ Load test completed"

# Чекаємо завершення моніторингу
wait $MONITOR_PID
echo "✅ Monitoring completed"

# Генеруємо звіт
echo ""
echo "📊 Generating test report..."
echo "=========================================="
echo "AUTOSCALING TEST REPORT"
echo "=========================================="
echo "Test Duration: ${TEST_DURATION}s"
echo "Target URL: $TARGET_URL"
echo ""

# Показуємо фінальний статус HPA
echo "Final HPA Status:"
kubectl get hpa database-app-hpa 2>/dev/null || echo "HPA not found (running locally?)"

# Показуємо фінальний статус подів
echo ""
echo "Final Pod Status:"
kubectl get pods -l app=database-app 2>/dev/null || echo "Pods not found (running locally?)"

# Показуємо логи масштабування
echo ""
echo "Scaling Events (last 20):"
kubectl get events --sort-by='.lastTimestamp' | grep -i "scaled\|hpa" | tail -20 2>/dev/null || echo "No scaling events found"

echo ""
echo "📁 Check scaling-monitor.log for detailed monitoring data"
echo "📁 Check load_test.log for load test results"
echo ""

echo "✅ Autoscaling test completed successfully!"
