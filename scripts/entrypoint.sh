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

if [ -f /var/www/html/config/config.php ]; then
echo "[Nextcloud Install] Nextcloud nicht gefunden. Installiere Nextcloud..."
php /var/www/server/occ maintenance:install \
    --database="${db_driver}" \
    --database-name="${db_name}" \
    --database-user="${db_username}" \
    --database-pass="${db_password}" \
    --admin-user="${nc_username}" \
    --admin-pass="${nc_password}" \
    --data-dir="/home/data" \
    --database-host="db"
    if grep -q "'installed' => true" /var/www/html/config/config.php; then
        echo "[Nextcloud Install] Nextcloud ist erfolgreich installiert worden"
    else
        echo "[Nextcloud Install] NExtcloud konnte nicht installiert werden."
    fi
else
  echo "[Nextcloud Install] Nextcloud bereits installiert."
fi


touch /var/www/server/config/myconfig.config.php
./config.sh > /var/www/server/config/myconfig.config.php

chown -R www-data:www-data /home/data
touch /etc/apache2/sites-enabled/000-default.conf
./apacheconfig.sh > /etc/apache2/sites-enabled/000-default.conf
for file in \
  /var/www/server/config/config.php \
  /var/www/server/config/myconfig.config.php
do
if [ -f "$file" ]; then
  if [ -s "$file" ]; then
    echo "[Konfigurator] $file Ist vorhanden"
  else
    echo "[Konfigurator] $file Ist vorhanden, aber ist leer"
  fi
else
  echo "[Konfigurator] $file Ist NICHT vorhanden"
fi
done

chown -R www-data:www-data /var/www/server/config
echo "[Nextcloud Install] Nextcloud maintenance:repair Job wird durchgeführt"
php /var/www/server/occ maintenance:repair --include-expensive > /dev/null
echo "[Nextcloud Install] Nextcloud maintenance:repair Job ist zu Ende"
echo "[Nextcloud Install]"
sudo -u www-data /var/www/server/occ app:disable files_reminders

echo "Ended script"
exec apache2ctl -D FOREGROUND 
