#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Wait for MariaDB to be ready
echo -e "${CYAN}Waiting for MariaDB to be ready...${NC}"
until mysqladmin ping -h "${MYSQL_DB_HOST}" -u root --password="${MYSQL_ROOT_PASSWORD}" --silent; do
    sleep 1
done

echo -e "${CYAN}MariaDB is ready. Proceeding with WordPress setup...${NC}"

# Main script starts here
# cd /var/www/html
# curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# chmod +x wp-cli.phar
# mv wp-cli.phar /usr/local/bin/wp

# Check that the admin user does not contain forbidden substrings
if echo "${WORDPRESS_ADMIN_USER}" | grep -i -qE "admin|administrator"; then
    echo -e "${RED}Error: WORDPRESS_ADMIN_USER contains forbidden substrings (admin, administrator).${NC}"
    exit 1
fi

# ./wp-cli.phar core download --allow-root


# ./wp-cli.phar config create \
#             --dbname=${WORDPRESS_DB_NAME} \
#             --dbuser=${WORDPRESS_DB_USER} \
#             --dbpass=${WORDPRESS_DB_PASSWORD} \
#             --dbhost=${WORDPRESS_DB_HOST} \
#             --allow-root

# ./wp-cli.phar core install \
#                 --url=${DOMAIN_NAME} \
#                 --title=${WORDPRESS_TITLE} \
#                 --admin_user=${WORDPRESS_ADMIN_USER} \
#                 --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
#                 --admin_email=${WORDPRESS_ADMIN_EMAIL} \
#                 --allow-root
if [ ! -f /var/www/html/wp-config.php ]; then
    echo -e "${CYAN}Creating wp-config.php...${NC}"
    wp config create --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${MYSQL_DB_HOST}" \
        --allow-root
else
    echo -e "${CYAN}wp-config.php already exists. Skipping creation.${NC}"
fi


if ! wp core is-installed --path=/var/www/html --allow-root; then
    echo -e "${CYAN}Installing WordPress...${NC}"
    # ./wp-cli.phar core download --allow-root #TODO: check if this is needed
    wp core install --path=/var/www/html \
        --url=http://${DOMAIN_NAME} \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email --allow-root

    echo "Creating a regular user..."
    wp user create "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" \
        --user_pass="${WORDPRESS_USER_PASSWORD}" --role=subscriber \
        --path=/var/www/html --allow-root

    echo -e "${GREEN}WordPress installation complete.${NC}"
else
    echo -e "${CYAN}WordPress is already installed. Skipping setup.${NC}"
fi