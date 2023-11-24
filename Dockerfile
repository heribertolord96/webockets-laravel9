# Dockerfile basic for centos image
FROM centos:7


## As sudo
ENV COMPOSER_ALLOW_SUPERUSER=1

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


# RUN yum -y install epel-release && \# Instalar herramientas esenciales y repositorios
RUN yum install -y epel-release yum-utils && \
    yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y && \
    yum-config-manager --enable remi-php74 && \
    yum install -y httpd php php-cli php-common php-mysqlnd php-zip php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json libsqlite3-dev

# RUN yum install -y epel-release yum-utils && \
#     yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y && \
#     yum-config-manager --enable remi-php81 -y

COPY apache-sample.html /var/www/html/index.html
# Instalar Apache, PHP, y otras dependencias
# RUN yum install -y \
#     httpd \
#     mod_ssl \
#     php \
#     php-cli \
#     php-zip \
#     wget \
#     unzip \
#     git \
#     libzip-dev \
#     libpng-dev \
#     libjpeg-dev \
#     libfreetype6-dev \
#     libsqlite3-dev\
#     libxml2-dev \
#     zlib1g-dev \
#     supervisor

# RUN yum update -y &&  yum -y install phpmyadmin
# EXPOSE  443
EXPOSE 80
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
