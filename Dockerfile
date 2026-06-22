FROM php:8.3-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libfreetype6-dev \
    libicu-dev \
    libgmp-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    libzip-dev \
    unzip \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-configure intl

# Instalar extensiones PHP
RUN docker-php-ext-install \
    bcmath \
    calendar \
    exif \
    gd \
    gmp \
    intl \
    mysqli \
    pdo \
    pdo_mysql \
    zip

# Instalar Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/local/bin/composer

# Directorio de trabajo
WORKDIR /var/www/html

# Copiar proyecto
COPY . .

# Instalar dependencias PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Configurar Apache para Laravel/Krayin
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

# Permitir .htaccess
RUN printf '<Directory "/var/www/html/public">\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>\n' \
>> /etc/apache2/apache2.conf

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Permisos de Laravel
RUN mkdir -p storage bootstrap/cache

RUN chmod -R 775 storage bootstrap/cache
RUN chown -R www-data:www-data storage bootstrap/cache

# Exponer puerto
EXPOSE 80

# Script de arranque
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
