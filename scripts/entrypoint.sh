#!/bin/bash
db_driver="${NC_DB_DRIVER:-mysql}"
db_name="${MYSQL_DATABASE:-nextcloud}"
db_username="${MYSQL_USER:-ncloud}"
db_password="${MYSQL_PASSWORD:-ncloud}"
nc_username="${NC_USERNAME:-ncloud}"
nc_password="${NC_PASSWORD:-admin}"

SSL_DIR="/etc/apache2/ssl"
CRT_FILE=""
KEY_FILE=""

echo "Installing Nextcloud..."
CRT_FILE=$(find "$SSL_DIR" -maxdepth 1 -type f -name '*.crt' | head -n1)
KEY_FILE=$(find "$SSL_DIR" -maxdepth 1 -type f -name '*.key' | head -n1)

if [ -z "$CRT_FILE" ] || [ -z "$KEY_FILE" ]; then
  echo "[SSL Skript] Keine Zertifikat/Schlüssel gefunden. Erstelle neue"

  CRT_FILE="$SSL_DIR/selfsigned.crt"
  KEY_FILE="$SSL_DIR/selfsigned.key"

  mkdir -p "$SSL_DIR"

  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=DE/ST=Bayern/L=Nürnberg/O=Netways GmbH/CN=localhost" \
    -keyout "$KEY_FILE" \
    -out    "$CRT_FILE"
else
  echo "[SSL Skript] Zertifikat gefunden: $CRT_FILE"
  echo "[SSL Skript] Schlüssel gefunden: $KEY_FILE"
fi

export SSL_CERT_PATH="$CRT_FILE"
export SSL_KEY_PATH="$KEY_FILE"

echo "[SSL Skript] Exportiert ENV SSL_CERT_PATH=$SSL_CERT_PATH"
echo "[SSL Skript] Exportiert ENV SSL_KEY_PATH=$SSL_KEY_PATH"
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
touch /etc/apache2/sites-enabled/000-default.conf
./config.sh > /var/www/server/config/myconfig.config.php
./apacheconfig.sh > /etc/apache2/sites-enabled/000-default.conf

chown -R www-data:www-data /var/www/server/config

php /var/www/server/occ maintenance:repair --include-expensive

sudo -u www-data /var/www/server/occ app:disable files_reminders

echo "Ended script"
exec apache2ctl -D FOREGROUND
