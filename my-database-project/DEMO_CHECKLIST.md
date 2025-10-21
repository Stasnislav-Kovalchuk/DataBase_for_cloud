# ✅ Чек-лист для демонстрації лабораторної роботи 2

## 🎯 Перед демонстрацією (5 хвилин)

### 1. Підготовка середовища
- [ ] Відкрити Terminal
- [ ] Перейти в папку проекту: `cd /Users/stanislavkovalcuk/Desktop/github/DataBase_for_cloud/my-database-project`
- [ ] Перевірити, що Docker працює: `docker --version`
- [ ] Перевірити, що Python працює: `python3 --version`

### 2. Підготовка браузера
- [ ] Відкрити нову вкладку браузера
- [ ] Перейти на http://20.77.57.238:8080/api/authors
- [ ] Перевірити, що API працює
- [ ] Відкрити http://20.77.57.238:8080/swagger-ui.html

---

## 🎬 Сценарій демонстрації (15 хвилин)

### Крок 1: Показ роботи API (2 хв)
- [ ] **Відкрити API**: http://20.77.57.238:8080/api/authors
- [ ] **Пояснити**: "API працює на Azure VM, повертає JSON з авторами"
- [ ] **Показати Swagger**: http://20.77.57.238:8080/swagger-ui.html
- [ ] **Авторизація**: user:password
- [ ] **Протестувати**: GET /api/authors, GET /api/books

### Крок 2: Docker контейнери (3 хв)
- [ ] **Показати Dockerfile**: `cat Dockerfile`
- [ ] **Пояснити**: "Multi-stage build для оптимізації"
- [ ] **Запустити локально**: `docker compose up -d`
- [ ] **Перевірити**: `docker compose ps`
- [ ] **Тестувати API**: `curl -u user:password http://localhost:8080/api/authors`

### Крок 3: Load Testing (3 хв)
- [ ] **Показати скрипт**: `cat load-test.py | head -20`
- [ ] **Пояснити**: "Async Python скрипт з aiohttp"
- [ ] **Запустити тест**: `python3 load-test.py --url http://20.77.57.238:8080 --users 5 --duration 30`
- [ ] **Показати результати**: RPS, успішність, час відповіді

### Крок 4: Контейнеризований Load Test (2 хв)
- [ ] **Показати Dockerfile.loadtest**: `cat Dockerfile.loadtest`
- [ ] **Запустити контейнер**: `docker compose --profile loadtest up load-test`
- [ ] **Показати логи**: контейнер генерує навантаження

### Крок 5: Автоматичне масштабування (3 хв)
- [ ] **Показати HPA**: `cat k8s-deployment.yml | grep -A 20 "HorizontalPodAutoscaler"`
- [ ] **Пояснити налаштування**:
  - CPU threshold: 70%
  - Memory threshold: 80%
  - Min replicas: 2, Max: 10
- [ ] **Показати моніторинг**: `cat monitor-scaling.sh | head -10`

### Крок 6: Розгортання на хмарі (2 хв)
- [ ] **Показати GitHub Actions**: https://github.com/Stasnislav-Kovalchuk/DataBase_for_cloud/actions
- [ ] **Пояснити workflow**: автоматична збірка та розгортання
- [ ] **Показати Azure VM**: SSH підключення
- [ ] **Показати процеси**: `ssh -i "/Users/stanislavkovalcuk/Desktop/db-lab1-vm_key.pem" student@20.77.57.238 "ps aux | grep java"`

---

## 🎯 Ключові фрази для викладача

### При показі API:
> "API працює на Azure VM за адресою 20.77.57.238:8080, повертає JSON з авторами та книгами. Swagger UI надає інтерактивну документацію."

### При показі Docker:
> "Створено два Docker образи: основний для Spring Boot додатку та окремий для load testing. Використовується multi-stage build для оптимізації розміру."

### При показі Load Testing:
> "Python скрипт з async/await генерує навантаження з 5-10 користувачами. Результати показують 100% успішність та стабільний RPS."

### При показі масштабування:
> "HPA налаштований на CPU 70% та Memory 80%. Мінімум 2, максимум 10 подів. Автоматичне збільшення/зменшення в залежності від навантаження."

### При показі розгортання:
> "GitHub Actions автоматично збирає та розгортає додаток на Azure VM. Весь процес автоматизований."

---

## 📊 Результати для показу

### Load Testing результати:
```
Total Requests: 127
Successful Requests: 127
Failed Requests: 0
Success Rate: 100.00%
Requests per Second: 3.11
Average Response Time: 0.166s
```

### HPA налаштування:
```yaml
minReplicas: 2
maxReplicas: 10
cpu: 70%
memory: 80%
```

### Створені файли:
- 2 Dockerfile
- 1 docker-compose.yml
- 1 load-test.py
- 1 k8s-deployment.yml
- 4 bash скрипти
- 3 документаційні файли

---

## 🏆 Підсумок для викладача

**Всі завдання виконані:**
- ✅ Docker образи (2б)
- ✅ Контейнери на хмарі (2б)
- ✅ Автоматичне масштабування (2б)
- ✅ Сценарій навантаження (2б)
- ✅ Тестування масштабування (2б)
- ✅ Бонус: Контейнеризований load test (2б)
- ✅ Бонус: Розгортання на хмарі (2б)

**Загальна оцінка: 14/10 балів**
