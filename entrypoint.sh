#!/bin/bash
set -e

echo "Iniciando Krayin..."

cd /var/www/html

# Crear .env si no existe
if [ ! -f .env ]; then
    echo "Creando .env..."

    cp .env.example .env

    sed -i "s|DB_HOST=.*|DB_HOST=${DB_HOST:-mysql}|" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_DATABASE:-krayin}|" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USERNAME:-root}|" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD:-root}|" .env
    sed -i "s|REDIS_HOST=.*|REDIS_HOST=${REDIS_HOST:-redis}|" .env

    php artisan key:generate --force
fi

echo "Esperando conexión con MySQL..."

until php artisan migrate --force
do
    echo "MySQL aún no está listo..."
    sleep 5
done

echo "Ejecutando seeders..."
php artisan db:seed --force || true

echo "Creando storage link..."
php artisan storage:link || true

echo "Optimizando Laravel..."
php artisan optimize || true

echo "Asignando permisos..."
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

echo "Iniciando Apache..."

exec apache2-foreground
