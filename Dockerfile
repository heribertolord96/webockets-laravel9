# Utiliza una imagen base oficial de CentOS
FROM centos:7

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install anything. The service you want to start must be a SystemD service.

# Instalar herramientas esenciales y repositorios
RUN yum install -y epel-release yum-utils && \
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y && \
    yum-config-manager --enable remi-php81 -y && \
    yum update -y

# Instalar Apache, PHP, y otras dependencias
RUN yum install -y httpd mod_ssl nginx php php-cli php-zip wget unzip git libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libsqlite3-dev libxml2-dev zlib1g-dev supervisor

# Configurar SSL
COPY mycert.crt /etc/pki/tls/certs/
COPY mycert.key /etc/pki/tls/private/
RUN sed -i '/SSLCertificateFile/c\SSLCertificateFile /etc/pki/tls/certs/mycert.crt' /etc/httpd/conf.d/ssl.conf && \
    sed -i '/SSLCertificateKeyFile/c\SSLCertificateKeyFile /etc/pki/tls/private/mycert.key' /etc/httpd/conf.d/ssl.conf

# Configuración de Apache
COPY my-apache-config.conf /etc/httpd/conf.d/vhost.conf
RUN mkdir -p /var/www/html/my_website/{public_html,logs} \
    && chown -R apache:apache /var/www/html/my_website/logs/  \
    && chmod -R 755 /var/www/html/my_website/logs/

RUN mkdir /etc/apache2/
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
# RUN service apache2 restart

# Instalar Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    HASH="$(wget -q -O - https://composer.github.io/installer.sig)" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# Instalar Node.js
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash - && \
    yum install -y nodejs

# Verificar instalaciones
RUN php -v && node -v

# Copiar archivos del proyecto
# COPY . /var/www/html
COPY /composer.* /var/www/html/my_website/public_html
COPY /package.* /var/www/html/my_website/public_html
WORKDIR /var/www/html/my_website/public_html

# Configuración de Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponer puertos
# EXPOSE 80 443

# Exponer el puerto 80
EXPOSE 80

# Comando para iniciar Apache cuando se inicie el contenedor
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

# RUN cd /var/www/html/my_website/ && pwd && ls
# CMD ["/usr/sbin/init"]
# Comando para iniciar Supervisor
# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

