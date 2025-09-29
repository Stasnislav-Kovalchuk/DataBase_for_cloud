# Швидкий запуск проєкту

## 1. Перевірка вимог
```bash
java -version    # має бути Java 17+
mvn -v          # має бути Maven
mysql --version # має бути MySQL 8.0+
```

## 2. Встановлення (якщо потрібно)
**macOS (Homebrew):**
```bash
brew install openjdk@17 maven mysql
brew services start mysql
```

## 3. Налаштування бази даних
```bash
# Створити БД
mysql -u root -e "CREATE DATABASE IF NOT EXISTS mydb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Застосувати схему та дані (опційно)
mysql -u root mydb < db/schema.sql
mysql -u root mydb < db/data.sql
```

## 4. Налаштування змінних середовища
```bash
# Якщо MySQL без пароля (за замовчуванням Homebrew)
export DB_HOST=localhost
export DB_USER=root
export DB_PASSWORD=""

# Якщо є пароль
export DB_PASSWORD="your_password"
```

## 5. Запуск проєкту
```bash
# Перейти в папку проєкту
cd my-database-project

# Варіант 1: Запуск через Maven (рекомендовано)
mvn spring-boot:run

# Варіант 2: Якщо перший не працює - зібрати JAR і запустити
mvn clean package
java -jar target/my-database-project-0.0.1-SNAPSHOT.jar

# Варіант 3: Запуск через Maven з явним вказанням плагіна
mvn org.springframework.boot:spring-boot-maven-plugin:run
```

## 6. Перевірка роботи
- **API**: http://localhost:8080/api/authors
- **Swagger UI**: http://localhost:8080/swagger-ui.html

## Швидкі тести
```bash
# Список авторів
curl http://localhost:8080/api/authors

# Створити автора
curl -X POST http://localhost:8080/api/authors \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Author","birthYear":1990}'

# Список книг
curl http://localhost:8080/api/books
```

## Якщо щось не працює
- **Порт 8080 зайнятий**: `lsof -nP -iTCP:8080 -sTCP:LISTEN` → `kill <PID>`
- **MySQL не запущений**: `brew services start mysql`
- **Помилка підключення**: перевірте `DB_HOST/DB_USER/DB_PASSWORD` та що БД `mydb` існує
- **400 при створенні книги**: передавайте існуючий `author.id`

---
**Повна документація**: див. `README.md`
