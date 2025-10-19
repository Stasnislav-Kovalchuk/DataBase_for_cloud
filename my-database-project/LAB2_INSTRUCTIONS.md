# Лабораторна робота 2: Контейнеризація та автоматичне масштабування

## Завдання

### Обов'язкові (10 балів)

1. **Створити Docker образи** (2б) ✅
2. **Завантажити контейнери на хмару** (2б) 
3. **Налаштувати автоматичне масштабування** (2б)
4. **Створити сценарій навантаження** (2б) ✅
5. **Протестувати масштабування** (2б)

### Бонусні (4 бали)

6. **Контейнеризувати сценарій навантаження** (2б) ✅
7. **Розгорнути сценарій на хмарі** (2б)

## Структура файлів

```
my-database-project/
├── Dockerfile                    # Docker образ для Spring Boot додатку
├── Dockerfile.loadtest          # Docker образ для load testing
├── docker-compose.yml           # Локальне тестування
├── load-test.py                 # Python скрипт для навантаження
├── requirements.txt             # Python залежності
├── run-load-test.sh            # Скрипт запуску тестів
├── azure-deploy.yml            # Azure Container Instances
├── k8s-deployment.yml          # Kubernetes з HPA
├── deploy-to-azure.sh          # Скрипт розгортання на Azure
├── monitor-scaling.sh          # Моніторинг масштабування
├── test-autoscaling.sh          # Комплексний тест
└── LAB2_INSTRUCTIONS.md        # Цей файл
```

## Крок 1: Локальне тестування

### Запуск з Docker Compose

```bash
# Запуск всіх сервісів
docker compose up -d

# Перевірка статусу
docker compose ps

# Перегляд логів
docker compose logs -f app

# Зупинка
docker compose down
```

### Тестування API

```bash
# Перевірка доступності
curl http://localhost:8080/api/authors

# Swagger UI
open http://localhost:8080/swagger-ui.html
```

## Крок 2: Load Testing

### Локальне тестування навантаження

```bash
# Встановлення Python залежностей
pip3 install -r requirements.txt

# Запуск тесту (10 користувачів, 60 секунд)
./run-load-test.sh

# Кастомний тест
python3 load-test.py --url http://localhost:8080 --users 20 --duration 120
```

### Контейнеризований load test

```bash
# Запуск load test в контейнері
docker compose --profile loadtest up load-test

# Або окремо
docker build -f Dockerfile.loadtest -t load-test .
docker run --network my-database-project_app-network load-test
```

## Крок 3: Розгортання на Azure

### Передумови

```bash
# Встановлення Azure CLI
az login

# Встановлення kubectl
az aks install-cli
```

### Розгортання

```bash
# Автоматичне розгортання
./deploy-to-azure.sh myResourceGroup myAKSCluster

# Або ручне розгортання
# 1. Створити ACR
az acr create --resource-group myResourceGroup --name myacr --sku Basic

# 2. Зібрати та завантажити образ
az acr login --name myacr
docker build -t myacr.azurecr.io/database-app:latest .
docker push myacr.azurecr.io/database-app:latest

# 3. Створити AKS кластер
az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 2 --attach-acr myacr

# 4. Отримати credentials
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

# 5. Застосувати deployment
kubectl apply -f k8s-deployment.yml
```

## Крок 4: Тестування автоматичного масштабування

### Моніторинг масштабування

```bash
# Запуск моніторингу
./monitor-scaling.sh 300

# Перегляд статусу HPA
kubectl get hpa

# Перегляд подів
kubectl get pods -l app=database-app

# Перегляд подій масштабування
kubectl get events --sort-by='.lastTimestamp'
```

### Комплексний тест

```bash
# Запуск повного тесту масштабування
./test-autoscaling.sh http://your-external-ip 180
```

## Крок 5: Перевірка результатів

### Логи масштабування

```bash
# Перегляд логів додатку
kubectl logs -l app=database-app

# Перегляд подій HPA
kubectl describe hpa database-app-hpa

# Статистика подів
kubectl top pods -l app=database-app
```

### Файли результатів

- `scaling-monitor.log` - детальний моніторинг масштабування
- `load_test.log` - результати load testing
- `kubectl get events` - події масштабування в Kubernetes

## Налаштування HPA

HPA налаштований на:
- **CPU threshold**: 70%
- **Memory threshold**: 80%
- **Min replicas**: 2
- **Max replicas**: 10
- **Scale up**: 2 поди за 60 секунд
- **Scale down**: 1 под за 60 секунд

## Бонусні завдання

### Контейнеризований load test

```bash
# Запуск в окремому контейнері
docker run --rm \
  -e TARGET_URL=http://your-service:8080 \
  -e USERS=20 \
  -e DURATION=120 \
  your-registry.azurecr.io/load-test:latest
```

### Розгортання load test на хмарі

```bash
# Створення deployment для load test
kubectl create deployment load-test --image=your-registry.azurecr.io/load-test:latest

# Запуск
kubectl run load-test --image=your-registry.azurecr.io/load-test:latest --rm -it
```

## Поширені проблеми

### Проблема: HPA не масштабує
```bash
# Перевірка метрик
kubectl top nodes
kubectl top pods

# Перевірка HPA статусу
kubectl describe hpa database-app-hpa
```

### Проблема: Поди не запускаються
```bash
# Перевірка статусу подів
kubectl get pods -l app=database-app
kubectl describe pod <pod-name>

# Перевірка логів
kubectl logs <pod-name>
```

### Проблема: Високе навантаження не генерується
```bash
# Перевірка load test
python3 load-test.py --url http://your-service --users 50 --duration 300

# Перевірка мережі
kubectl get services
```

## Очищення ресурсів

```bash
# Видалення deployment
kubectl delete -f k8s-deployment.yml

# Видалення AKS кластеру
az aks delete --resource-group myResourceGroup --name myAKSCluster

# Видалення ACR
az acr delete --resource-group myResourceGroup --name myacr

# Видалення resource group
az group delete --name myResourceGroup
```
