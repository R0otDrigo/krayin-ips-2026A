#!/bin/bash
set -e

echo "Iniciando Krayin..."

if [ ! -f .env ]; then
    cp .env.example .env

    sed -i "s|DB_HOST=.*|DB_HOST=${DB_HOST}|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_DATABASE}|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USERNAME}|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD}|" .env
    sed -i "s|REDIS_HOST=.*|REDIS_HOST=${REDIS_HOST}|" .env

    php artisan key:generate --force
fi

echo "Esperando MySQL..."

until php artisan migrate --force
do
    sleep 5
done

php artisan db:seed --force || true
php artisan storage:link || true
php artisan optimize

exec apache2-foreground
