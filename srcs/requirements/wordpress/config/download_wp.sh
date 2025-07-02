# Download and set up WordPress
mkdir -p /var/www/html && \
wget https://wordpress.org/latest.tar.gz && \
tar -xzf latest.tar.gz && \
mv wordpress/* /var/www/html/ && \
chown -R www-data:www-data /var/www/html && \
chmod -R 755 /var/www/html && \
rm -rf wordpress latest.tar.gz