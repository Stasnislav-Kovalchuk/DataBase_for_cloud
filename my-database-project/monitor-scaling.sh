#!/bin/bash

# Скрипт для моніторингу автоматичного масштабування
# Використання: ./monitor-scaling.sh [duration_in_seconds]

set -e

DURATION=${1:-300}  # 5 хвилин за замовчуванням
LOG_FILE="scaling-monitor.log"

echo "📊 Starting scaling monitor for ${DURATION} seconds"
echo "Log file: $LOG_FILE"
echo ""

# Очищаємо попередній лог
> $LOG_FILE

# Функція для логування з timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Функція для отримання статусу HPA
get_hpa_status() {
    kubectl get hpa database-app-hpa -o json | jq -r '.status | "Current: \(.currentReplicas), Desired: \(.desiredReplicas), CPU: \(.currentCPUUtilizationPercentage)%"'
}

# Функція для отримання статусу подів
get_pods_status() {
    kubectl get pods -l app=database-app --no-headers | wc -l
}

# Функція для отримання CPU/Memory використання
get_resource_usage() {
    kubectl top pods -l app=database-app --no-headers | awk '{print "Pod: " $1 ", CPU: " $2 ", Memory: " $3}'
}

log "🚀 Starting monitoring..."

# Основний цикл моніторингу
for ((i=0; i<DURATION; i+=10)); do
    log "=== Monitoring cycle $((i/10 + 1)) ==="
    
    # Статус HPA
    log "HPA Status: $(get_hpa_status)"
    
    # Кількість подів
    POD_COUNT=$(get_pods_status)
    log "Active Pods: $POD_COUNT"
    
    # Використання ресурсів
    log "Resource Usage:"
    get_resource_usage | while read line; do
        log "  $line"
    done
    
    # Статус deployment
    log "Deployment Status:"
    kubectl get deployment database-app -o json | jq -r '.status | "Ready: \(.readyReplicas), Available: \(.availableReplicas), Unavailable: \(.unavailableReplicas)"' | while read line; do
        log "  $line"
    done
    
    log ""
    
    # Чекаємо 10 секунд
    sleep 10
done

log "✅ Monitoring completed"
log "📈 Summary:"
log "Total monitoring time: ${DURATION} seconds"
log "Final pod count: $(get_pods_status)"
log "Final HPA status: $(get_hpa_status)"

echo ""
echo "📊 Monitoring completed. Check $LOG_FILE for detailed logs"
echo "To view real-time logs: tail -f $LOG_FILE"
