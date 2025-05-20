#!/bin/bash
service mariadb start
echo "Is mariadb up? ..."
for i in {1..30}; do 
    if mysqladmin ping &>/dev/null; then
        echo "Maridb is up"
        break
    fi 
    echo -n "."
    sleep 1
done

db_driver="${NC_DB_DRIVER:-mysql}"
db_name="${NC_DB_NAME:-nextcloud}"
db_username="${NC_DB_USERNAME:-ncloud}"
db_password="${NC_DB_PASSWORD:-ncloud}"
nc_username="${NC_USERNAME:-ncloud}"
nc_password="${NC_PASSWORD:-admin}"

echo "$db_driver $db_name $db_password"

mariadb -e "CREATE USER '${db_username}'@'localhost' IDENTIFIED BY '${db_password}'; 
CREATE DATABASE ${db_name};
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_username}'@'localhost';
FLUSH PRIVILEGES;" 

echo "Installing Nextcloud..."

sudo -u www-data php /var/www/server/occ maintenance:install \
    --database="${db_driver}" \
    --database-name="${db_name}" \
    --database-user="${db_username}" \
    --database-pass="${db_password}" \
    --admin-user="${nc_username}" \
    --admin-pass="${nc_password}" \
    --data-dir="/home/data"

echo "Ended script"
exec apache2ctl -D FOREGROUND
