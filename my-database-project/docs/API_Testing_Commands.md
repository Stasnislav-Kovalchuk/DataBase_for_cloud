# API Testing Commands - Spring Boot Backend

## Базові налаштування

**Сервер:** `http://20.77.57.238:8080`  
**Авторизація:** Basic Auth (`user:password` або `admin:strongpass`)

## 1. Перевірка доступності

```bash
# Перевірка доступності API
curl -I http://20.77.57.238:8080/api/authors

# Перевірка Swagger UI (без авторизації)
curl -I http://20.77.57.238:8080/swagger-ui.html
```

## 2. Тестування авторів

### GET - Отримати список авторів
```bash
curl -u user:password -s http://20.77.57.238:8080/api/authors | jq
```

### GET - Отримати автора за ID
```bash
curl -u user:password -s http://20.77.57.238:8080/api/authors/1 | jq
```

### POST - Створити автора
```bash
curl -u user:password -X POST http://20.77.57.238:8080/api/authors \
  -H "Content-Type: application/json" \
  -d '{"name":"Isaac Asimov","birthYear":1920}' | jq
```

### PUT - Оновити автора
```bash
curl -u user:password -X PUT http://20.77.57.238:8080/api/authors/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Isaac Asimov Updated","birthYear":1920}' | jq
```

### DELETE - Видалити автора
```bash
curl -u user:password -X DELETE http://20.77.57.238:8080/api/authors/1
```

## 3. Тестування книг

### GET - Отримати список книг
```bash
curl -u user:password -s http://20.77.57.238:8080/api/books | jq
```

### GET - Отримати книгу за ID
```bash
curl -u user:password -s http://20.77.57.238:8080/api/books/1 | jq
```

### POST - Створити книгу
```bash
curl -u user:password -X POST http://20.77.57.238:8080/api/books \
  -H "Content-Type: application/json" \
  -d '{"title":"Foundation","yearPublished":1951,"author":{"id":1}}' | jq
```

### PUT - Оновити книгу
```bash
curl -u user:password -X PUT http://20.77.57.238:8080/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Foundation Updated","yearPublished":1951,"author":{"id":1}}' | jq
```

### DELETE - Видалити книгу
```bash
curl -u user:password -X DELETE http://20.77.57.238:8080/api/books/1
```

## 4. Повний тестовий сценарій

```bash
#!/bin/bash
echo "=== Повне тестування API з Basic Auth ==="

# Креденшіали
USER="user"
PASS="password"
BASE_URL="http://20.77.57.238:8080"

echo "1. Перевіряємо список авторів..."
curl -u $USER:$PASS -s $BASE_URL/api/authors | jq

echo "2. Створюємо автора..."
AUTHOR_RESPONSE=$(curl -u $USER:$PASS -s -X POST $BASE_URL/api/authors \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Author","birthYear":1990}')
echo "Автор створений: $AUTHOR_RESPONSE"

# Витягуємо ID автора
AUTHOR_ID=$(echo $AUTHOR_RESPONSE | jq -r '.id')
echo "ID автора: $AUTHOR_ID"

echo "3. Отримуємо автора за ID..."
curl -u $USER:$PASS -s $BASE_URL/api/authors/$AUTHOR_ID | jq

echo "4. Створюємо книгу..."
curl -u $USER:$PASS -X POST $BASE_URL/api/books \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Test Book\",\"yearPublished\":2024,\"author\":{\"id\":$AUTHOR_ID}}" | jq

echo "5. Список книг..."
curl -u $USER:$PASS -s $BASE_URL/api/books | jq

echo "6. Оновлюємо автора..."
curl -u $USER:$PASS -X PUT $BASE_URL/api/authors/$AUTHOR_ID \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Author Updated","birthYear":1990}' | jq

echo "7. Фінальний список авторів..."
curl -u $USER:$PASS -s $BASE_URL/api/authors | jq

echo "=== Тест завершено ==="
```

## 5. Тестування помилок

### Тест неавторизованого доступу
```bash
# Має повернути 401 Unauthorized
curl -i http://20.77.57.238:8080/api/authors
```

### Тест невалідних креденшіалів
```bash
# Має повернути 401 Unauthorized
curl -u wrong:password http://20.77.57.238:8080/api/authors
```

### Тест неіснуючого ресурсу
```bash
# Має повернути 404 Not Found
curl -u user:password -s http://20.77.57.238:8080/api/authors/999 | jq
```

### Тест невалідних даних
```bash
# Має повернути 400 Bad Request
curl -u user:password -X POST http://20.77.57.238:8080/api/books \
  -H "Content-Type: application/json" \
  -d '{"title":"","author":{"id":999}}' | jq
```

## 6. Навантажувальне тестування

### Простий тест навантаження
```bash
# 100 запитів, 10 одночасно
for i in {1..10}; do
  curl -u user:password -s http://20.77.57.238:8080/api/authors > /dev/null &
done
wait
echo "10 паралельних запитів завершено"
```

### Тест з Apache Bench (якщо встановлено)
```bash
# Встановити ab
sudo apt-get install apache2-utils

# Тест навантаження
ab -n 100 -c 10 -u user:password http://20.77.57.238:8080/api/authors
```

## 7. Моніторинг відгуку

### Час відгуку з деталями
```bash
curl -u user:password -w "Час підключення: %{time_connect}s\nЧас відгуку: %{time_total}s\n" \
  -o /dev/null -s http://20.77.57.238:8080/api/authors
```

### Тест з таймаутом
```bash
curl -u user:password --max-time 5 http://20.77.57.238:8080/api/authors
```

## 8. Збереження результатів

### Зберегти відповідь у файл
```bash
curl -u user:password -s http://20.77.57.238:8080/api/authors > authors.json
```

### Логування всіх запитів
```bash
curl -u user:password -v http://20.77.57.238:8080/api/authors 2>&1 | tee curl.log
```

## 9. Альтернативні креденшіали

### З новими креденшіалами
```bash
# Якщо змінили на admin:strongpass
curl -u admin:strongpass -s http://20.77.57.238:8080/api/authors | jq
```

### З змінними середовища
```bash
export API_USER="user"
export API_PASS="password"
curl -u $API_USER:$API_PASS -s http://20.77.57.238:8080/api/authors | jq
```

## 10. Корисні аліаси

### Додати в ~/.bashrc або ~/.zshrc
```bash
# Аліас для швидкого тестування
alias api-test='curl -u user:password -s http://20.77.57.238:8080/api/authors | jq'

# Аліас для створення автора
alias api-create-author='curl -u user:password -X POST http://20.77.57.238:8080/api/authors -H "Content-Type: application/json" -d'

# Використання
api-test
api-create-author '{"name":"Quick Author","birthYear":1990}' | jq
```

## 11. Перевірка статусу сервера

### Health check (якщо налаштовано)
```bash
curl -s http://20.77.57.238:8080/actuator/health | jq
```

### Перевірка через браузер
- **Swagger UI:** http://20.77.57.238:8080/swagger-ui.html
- **API (потребує авторизації):** http://20.77.57.238:8080/api/authors

---

**Примітки:**
- Замініть `user:password` на ваші креденшіали
- Якщо немає `jq`, видаліть `| jq` з команд
- Для Windows використовуйте Git Bash або PowerShell
- Всі команди протестовані на macOS/Linux
