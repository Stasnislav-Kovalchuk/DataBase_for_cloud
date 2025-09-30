# My Database Project (Java 17 + Spring Boot)

Репозиторій-шаблон для лабораторних робіт з предмету "Бази даних і знань". Проєкт містить базовий бекенд на Spring Boot з REST-CRUD для авторів та книг, SQL-скрипти і Swagger-UI.

## Вміст
- Пререквізити
- Структура проєкту
- Налаштування БД (MySQL)
- Конфігурація застосунку (env → application.properties)
- Запуск (локально через Maven)
- REST API (ендпоїнти і приклади cURL)
- Swagger-UI
- Робота з SQL-скриптами (schema.sql, data.sql)
- Поширені помилки та усунення
- Додатково

## Пререквізити
- Java 17 (або JDK 17+; перевірка: `java -version`)
- Maven (перевірка: `mvn -v`)
- MySQL Server 8.0+ (або 9.x)

macOS (Homebrew):
```bash
brew install openjdk@17 maven mysql
brew services start mysql
```
Примітка: MySQL через Homebrew зазвичай встановлюється без пароля для користувача `root`.

## Структура проєкту
```
еуие
my-database-project/
├── src/
├── db/
│   ├── schema.sql
│   ├── data.sql
│   └── diagrams/
├── README.md
└── .gitignore
```

## Налаштування БД (MySQL)
Створіть базу даних `mydb` та (за потреби) застосуйте скрипти:
```bash
# створення БД
mysql -u root -e "CREATE DATABASE IF NOT EXISTS mydb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# застосування DDL/даних (за потреби)
mysql -u root mydb < db/schema.sql
mysql -u root mydb < db/data.sql
```
Якщо у вас пароль на `root`, додайте `-pYOUR_PASSWORD` або використайте змінні середовища знизу.

## Конфігурація застосунку
Параметри в `src/main/resources/application.properties` читають змінні середовища:
```
spring.datasource.url=jdbc:mysql://${DB_HOST:localhost}:3306/mydb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=${DB_USER:root}
spring.datasource.password=${DB_PASSWORD:password}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
springdoc.api-docs.enabled=true
springdoc.swagger-ui.path=/swagger-ui.html
```
Приклади експорту (macOS/Linux):
```bash
export DB_HOST=localhost
export DB_USER=root
export DB_PASSWORD=""   # якщо root без пароля (Homebrew за замовчуванням)
```

## Запуск (локально через Maven)
```bash
mvn spring-boot:run
```
або зібрати JAR і запустити:
```bash
mvn clean package
java -jar target/my-database-project-0.0.1-SNAPSHOT.jar
```
Додаток стартує на `http://localhost:8080`.

## REST API
- Автори: `/api/authors`
  - GET `/api/authors` — список авторів
  - GET `/api/authors/{id}` — отримати автора
  - POST `/api/authors` — створити автора
  - PUT `/api/authors/{id}` — оновити автора
  - DELETE `/api/authors/{id}` — видалити автора
- Книги: `/api/books`
  - GET `/api/books` — список книг
  - GET `/api/books/{id}` — отримати книгу
  - POST `/api/books` — створити книгу (потрібен `author.id`)
  - PUT `/api/books/{id}` — оновити книгу
  - DELETE `/api/books/{id}` — видалити книгу

### Приклади cURL
```bash
# (1) Автора — список
curl -s http://localhost:8080/api/authors

# (2) Створити автора
curl -s -X POST http://localhost:8080/api/authors \
  -H "Content-Type: application/json" \
  -d '{"name":"Isaac Asimov","birthYear":1920}'

# (3) Книги — створити книгу з прив'язкою до існуючого автора (id=1)
curl -s -X POST http://localhost:8080/api/books \
  -H "Content-Type: application/json" \
  -d '{"title":"Foundation","yearPublished":1951,"author":{"id":1}}'

# (4) Книги — список
curl -s http://localhost:8080/api/books
```

## Swagger-UI
Інтерактивна документація доступна після старту застосунку:
```
http://localhost:8080/swagger-ui.html
```

## Робота з SQL-скриптами
- `db/schema.sql` — створення таблиць `authors`, `books` (FK на `authors.id`).
- `db/data.sql` — приклад наповнення (2 автори, 2 книги).
- `db/diagrams/` — папка для ER-діаграм (додайте власні файли/зображення).

Повторний запуск скриптів (обережно з даними в існуючій БД):
```bash
mysql -u root mydb < db/schema.sql
mysql -u root mydb < db/data.sql
```

## Поширені помилки та усунення
- Порт 8080 зайнятий:
  - Знайти процес: `lsof -nP -iTCP:8080 -sTCP:LISTEN`
  - Завершити: `kill <PID>` або запустити на іншому порту: `--server.port=8081`
- Помилка з’єднання з MySQL (Communications link failure):
  - Переконайтесь, що MySQL запущено: `brew services start mysql`
  - Перевірте доступ: `mysql -u root` (або з паролем)
  - Перевірте `DB_HOST/DB_USER/DB_PASSWORD` і що `mydb` існує
- 400 при створенні книги:
  - Передавайте валідний `author.id`, який існує в таблиці `authors`
- 500 при GET `/api/books`:
  - Виправлено конфігурацією серіалізації і EAGER-завантаженням автора. Якщо повторюється — перевірте логи застосунку.

## Додатково
- Зміна порту:
```properties
server.port=8081
```
- Профілі середовищ (prod/dev): додайте `application-dev.properties`, запускайте з `--spring.profiles.active=dev`.
- Форматування логів SQL: керується `spring.jpa.show-sql`.

---
Якщо потрібні Docker-композ-файли, міграції (Flyway/Liquibase) або додаткові сутності — скажіть, додам у шаблон.
