#!/bin/bash
set -e

if [ ! -f .env ]; then
    cp .env.example .env

    php artisan key:generate --force

    php artisan storage:link || true
fi

exec apache2-foreground
