#!/usr/bin/env bash
set -euo pipefail

# Simple Ubuntu setup script for Azure VM
# - Installs OpenJDK 17, Maven, MySQL Server
# - Creates DB, app user, and example .env
# - Prints next steps

if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root: sudo $0" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y openjdk-17-jre-headless maven mysql-server curl jq

systemctl enable mysql
systemctl start mysql

DB_NAME=${DB_NAME:-mydb}
DB_USER=${DB_USER:-app}
DB_PASSWORD=${DB_PASSWORD:-app_password}

mysql --protocol=socket <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS \`${DB_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@'%';
FLUSH PRIVILEGES;
SQL

# Allow remote connections if needed (optional)
sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf || true
systemctl restart mysql

APP_DIR=${APP_DIR:-/opt/my-database-project}
mkdir -p "${APP_DIR}"

cat > "${APP_DIR}/.env" <<ENV
# Application environment variables
DB_HOST=${DB_HOST:-localhost}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
SERVER_PORT=${SERVER_PORT:-8080}
JAVA_OPTS=${JAVA_OPTS:--Xms128m -Xmx256m}
ENV

echo "Setup done. Created DB '${DB_NAME}', user '${DB_USER}'."
echo "An .env file was written to ${APP_DIR}/.env"
echo "Next: copy project files to ${APP_DIR}, build JAR, and create systemd service."


