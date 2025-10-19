# Простий Dockerfile для Spring Boot додатку
FROM openjdk:17-jdk-slim

# Встановлюємо робочу директорію
WORKDIR /app

# Встановлюємо Maven
RUN apt-get update && \
    apt-get install -y maven curl && \
    rm -rf /var/lib/apt/lists/*

# Копіюємо pom.xml та завантажуємо залежності
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Копіюємо вихідний код
COPY src ./src

# Збираємо додаток
RUN mvn clean package -DskipTests

# Відкриваємо порт
EXPOSE 8080

# Додаємо health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Запускаємо додаток
CMD ["java", "-jar", "target/my-database-project-0.0.1-SNAPSHOT.jar"]