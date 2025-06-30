FROM debian:latest

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php-fpm \
    && apt-get clean

CMD ["php-fpm8.2", "-F"]