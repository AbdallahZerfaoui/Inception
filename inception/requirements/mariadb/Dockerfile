FROM debian:bookworm-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    mariadb-server \
    && apt-get clean

COPY config/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY config/init.sql /etc/mysql/

RUN mkdir -p /run/mysqld

CMD ["mysqld_safe"]