#!/bin/bash
db_driver="${NC_DB_DRIVER:-mysql}"
db_name="${MYSQL_DATABASE:-nextcloud}"
db_username="${MYSQL_USER:-ncloud}"
db_password="${MYSQL_PASSWORD:-ncloud}"
nc_username="${NC_USERNAME:-ncloud}"
nc_password="${NC_PASSWORD:-admin}"


echo "Installing Nextcloud..."


php /var/www/server/occ maintenance:install \
    --database="${db_driver}" \
    --database-name="${db_name}" \
    --database-user="${db_username}" \
    --database-pass="${db_password}" \
    --admin-user="${nc_username}" \
    --admin-pass="${nc_password}" \
    --data-dir="/home/data" \
    --database-host="db"

chown -R www-data:www-data /home/data
touch /var/www/server/config/myconfig.config.php
./config.sh > /var/www/server/config/myconfig.config.php

chown -R www-data:www-data /var/www/server/config
chown -R www-data:www-data /var/www/server/apps

php /var/www/server/occ maintenance:repair --include-expensive

sudo -u www-data /var/www/server/occ app:disable files_reminders

echo "Ended script"
exec apache2ctl -D FOREGROUND
