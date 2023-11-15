# Utiliza una imagen base de Linux con PHP 7.3
FROM couchbase/centos7-systemd:latest
# FROM php:8.1

ENV COMPOSER_ALLOW_SUPERUSER=1

#Add ssl certs
# Instalar Apache (httpd) y módulos necesarios
RUN yum install -y httpd mod_ssl

# Habilitar el módulo rewrite (generalmente está habilitado por defecto en httpd)
# No hay un comando equivalente directo a a2enmod en CentOS,
# ya que los módulos suelen estar habilitados por defecto o a través de la instalación de paquetes específicos.

# Configurar SSL - Reemplazar los certificados SSL predeterminados
RUN sed -i '/SSLCertificateFile.*snakeoil\.pem/c\SSLCertificateFile \/etc\/pki\/tls\/certs\/mycert.crt' \
    /etc/httpd/conf.d/ssl.conf && \
    sed -i '/SSLCertificateKeyFile.*snakeoil\.key/c\SSLCertificateKeyFile /etc/pki/tls/private/mycert.key' \
    /etc/httpd/conf.d/ssl.conf
# En CentOS, el sitio SSL por defecto ya viene habilitado en la configuración de httpd,
# por lo que no es necesario un comando equivalente a a2ensite.
RUN yum install epel-release yum-utils -y
RUN yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
RUN yum-config-manager --enable remi-php81 -y


RUN yum update && yum install -y \
    php \
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
RUN yum install -y nodejs
RUN yum install -y npm

# Habilita las extensiones PHP necesarias
# RUN docker-php-ext-configure gd --with-freetype --with-jpeg
# RUN docker-php-ext-install gd pdo pdo_sqlite zip xml

# Copia el proyecto Laravel en el directorio /var/www/html
COPY /composer.* /var/www/html
COPY /package.* /var/www/html
WORKDIR /var/www/html

# Instala las dependencias de Composer y de Node.js
# RUN composer clear-cache
# RUN composer config --global --auth github-oauth.github.com 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
# RUN composer install
# RUN npm install

# Configura Supervisor para el proyecto Laravel Echo Server (websockets)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expon el puerto 8000 para el servidor Laravel
EXPOSE 8000

# Ejecuta el servidor Laravel con "php artisan serve"
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
