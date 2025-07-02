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
COPY config/download_wp.sh .
COPY config/handle_wp-cli.sh .
COPY config/init_wp.sh .
COPY config/run.sh .

RUN chmod +x init_wp.sh download_wp.sh handle_wp-cli.sh run.sh

CMD ["./run.sh"]