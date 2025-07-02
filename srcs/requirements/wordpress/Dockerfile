FROM debian:bookworm-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php-fpm \
    php-mysql \
    curl \
    wget \
    unzip \
    mariadb-client \
    && apt-get clean

COPY config/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY config/init_wp.sh .
COPY config/download_wp.sh .

RUN chmod +x init_wp.sh download_wp.sh
RUN ./download_wp.sh

CMD ["./init_wp.sh"]