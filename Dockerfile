FROM php:7.0-fpm

MAINTAINER "Zak Henry" <zak.henry@gmail.com>

RUN mkdir -p /data
WORKDIR /data

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    libmcrypt-dev \
    libxml2-dev \
    python-pip \
    nginx

RUN pip install --upgrade supervisor supervisor-stdout

RUN docker-php-ext-install mcrypt pdo_pgsql mbstring pdo_mysql sockets opcache soap

RUN pecl install xdebug-beta && \
    docker-php-ext-enable xdebug

# Configure php
ADD config/memory.ini /opt/etc/memory.ini
ADD config/xdebug.ini /opt/etc/xdebug.ini

RUN cat /opt/etc/memory.ini >> /usr/local/etc/php/conf.d/memory.ini

# Configure nginx
ADD config/nginx.conf /etc/nginx/nginx.conf

# Add supervisor config file
ADD config/supervisord.conf /etc/supervisor/supervisord.conf

# Startup scripts
# supervisord startup script
ADD config/supervisord-start.sh /opt/bin/supervisord-start.sh
RUN chmod u=rwx /opt/bin/supervisord-start.sh
# Nginx startup script
ADD config/nginx-start.sh /opt/bin/nginx-start.sh
RUN chmod u=rwx /opt/bin/nginx-start.sh
# PHP startup script
ADD config/php-start.sh /opt/bin/php-start.sh
RUN chmod u=rwx /opt/bin/php-start.sh

ENTRYPOINT ["/opt/bin/supervisord-start.sh"]