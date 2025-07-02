FROM debian:bullseye-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php-fpm \
    php-mysql \
    curl \
    wget \
    unzip \
    mariadb-client \
    && apt-get clean

COPY config/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY config/*.sh .

# chown -R www-data:www-data /run/php: 
# Sets the owner of that directory to the www-data user 
# and group, giving PHP-FPM permission to write its files there.
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

# Ensure the scripts are executable
RUN chmod +x download_wp.sh handle_wp-cli.sh init_wp.sh

WORKDIR /var/www/html

CMD ["./init_wp.sh"]