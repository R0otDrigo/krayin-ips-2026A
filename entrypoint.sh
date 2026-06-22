#!/bin/bash
set -e

echo "Iniciando Krayin..."

cd /var/www/html

# Crear .env si no existe
if [ ! -f .env ]; then
    cp .env.example .env

    sed -i "s|DB_HOST=.*|DB_HOST=${DB_HOST:-mysql}|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_DATABASE:-krayin}|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USERNAME:-root}|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD:-root}|" .env
    sed -i "s|REDIS_HOST=.*|REDIS_HOST=${REDIS_HOST:-redis}|" .env
fi

# Generar APP_KEY si no existe
if ! grep -q "^APP_KEY=base64:" .env; then
    echo "Generando APP_KEY..."
    php artisan key:generate --force
fi

echo "Esperando MySQL..."

until php artisan migrate --force
do
    echo "MySQL aún no está listo..."
    sleep 5
done

php artisan db:seed --force || true
php artisan storage:link || true
php artisan optimize || true

chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

echo "Iniciando Apache..."
exec apache2-foreground
