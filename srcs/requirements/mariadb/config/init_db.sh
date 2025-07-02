#!/bin/bash

DB_DIR="/var/lib/mysql"

if [ ! -d "$DB_DIR/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --basedir=/usr --datadir="$DB_DIR"
fi

# 1. Start MariaDB in the background. The '&' is crucial.
#    We also add --skip-networking to prevent connections during setup.
mysqld_safe --datadir="$DB_DIR" & sleep 5

# 2. Wait until the server is responsive.
#    We will ping the socket file until it's ready.
until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock > /dev/null 2>&1; do
    echo "Waiting for MariaDB to be ready..."
    sleep 1
done

# 3. Now that the server is running, execute your setup commands.
echo "MariaDB is ready. Creating database and user..."
mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_ADMIN_USER}'@'%';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;"

mysql -e "FLUSH PRIVILEGES;"


# 4. Hand control over to the original entrypoint command.
#    This will restart mysqld properly in the foreground, now that setup is done.
# echo "Initialization complete. Starting MariaDB for connections..."
# exec "$@"
wait