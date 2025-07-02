#!/bin/bash

./download_wp.sh
./handle_wp-cli.sh
./init_wp.sh
php-fpm8.2 -F