FROM debian:bullseye-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    mariadb-server \
    && apt-get clean

COPY config/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY config/init.sql /etc/mysql/
COPY config/init_db.sh .

RUN chmod +x init_db.sh

RUN mkdir -p /run/mysqld

CMD ["./init_db.sh"]