FROM php:7.0-fpm

MAINTAINER "Zak Henry" <zak.henry@gmail.com>

RUN mkdir -p /data
VOLUME ["/data"]
WORKDIR /data

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    libmcrypt-dev \
    libxml2-dev \
    python-pip

RUN pip install --upgrade supervisor supervisor-stdout

RUN docker-php-ext-install mcrypt pdo_pgsql mbstring pdo_mysql sockets opcache soap

RUN pecl install xdebug-beta && \
    docker-php-ext-enable xdebug

# Configure php
ADD config/memory.ini /opt/etc/memory.ini
ADD config/xdebug.ini /opt/etc/xdebug.ini

RUN sed -i "s|%data-root%|/data|" /opt/etc/xdebug.ini

RUN cat /opt/etc/memory.ini >> /usr/local/etc/php/conf.d/memory.ini


# Configure nginx
ADD config/nginx.conf /etc/nginx/nginx.conf

# Add supervisor config file
ADD config/supervisord.conf /etc/supervisor/supervisord.conf


# PHP startup script
ADD config/webserver-start.sh /opt/bin/webserver-start.sh
RUN chmod u=rwx /opt/bin/webserver-start.sh

EXPOSE 80

ENTRYPOINT ["/opt/bin/webserver-start.sh"]