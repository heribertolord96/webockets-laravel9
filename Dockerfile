# Utiliza una imagen base de Linux con PHP 7.3
FROM php:8.1

ENV COMPOSER_ALLOW_SUPERUSER=1

# Actualiza el sistema y luego instala las dependencias necesarias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libsqlite3-dev \
    libxml2-dev \
    zlib1g-dev \
    supervisor

# Instala Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instala Node.js 14.x y npm
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# Habilita las extensiones PHP necesarias
# RUN docker-php-ext-configure gd --with-freetype --with-jpeg
# RUN docker-php-ext-install gd pdo pdo_sqlite zip xml

# Copia el proyecto Laravel en el directorio /var/www
COPY . /var/www
WORKDIR /var/www

# Instala las dependencias de Composer y de Node.js
RUN composer clear-cache
RUN  composer config --global --auth github-oauth.github.com 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
RUN composer update
RUN npm install

# Configura Supervisor para el proyecto Laravel Echo Server (websockets)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expon el puerto 8000 para el servidor Laravel
EXPOSE 8000

# Ejecuta el servidor Laravel con "php artisan serve"
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
