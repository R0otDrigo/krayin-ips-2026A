#!/bin/bash

echo "Levantando contenedores..."
docker compose up -d

echo "Esperando MySQL..."
sleep 30

APP_CONTAINER=$(docker ps --filter "name=app" --format "{{.Names}}")

echo "Instalando Krayin..."

docker exec $APP_CONTAINER bash -c "
cp .env.example .env

sed -i 's/DB_HOST=.*/DB_HOST=mysql/' .env
sed -i 's/DB_DATABASE=.*/DB_DATABASE=krayin/' .env
sed -i 's/DB_USERNAME=.*/DB_USERNAME=root/' .env
sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=root/' .env
sed -i 's/REDIS_HOST=.*/REDIS_HOST=redis/' .env

php artisan key:generate

php artisan krayin-crm:install \
    --skip-env-check \
    --skip-admin-creation

php artisan migrate --force

php artisan db:seed --force

php artisan storage:link

php artisan optimize:clear
"

echo "Krayin instalado correctamente."
echo "URL: http://localhost"
