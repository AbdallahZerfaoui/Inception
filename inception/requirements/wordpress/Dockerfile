FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php-fpm \
    && apt-get clean

COPY config/www.conf /etc/php/8.2/fpm/pool.d/www.conf

CMD ["php-fpm8.2", "-F"]