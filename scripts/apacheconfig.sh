#!/bin/sh
ip="$(curl -s https://ipinfo.io/ip | tr -d '\n')"
domain="${DOMAIN:-$ip}"
touch scriptdone2

cat<<EOF
<VirtualHost *:443>
        ServerAdmin             webmaster@localhost
        DocumentRoot            /var/www/server
        ServerName              localhost
        Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"

        SSLEngine on
        SSLCertificateFile      /etc/apache2/ssl/selfsigned.crt
        SSLCertificateKeyFile   /etc/apache2/ssl/selfsigned.key

        <Directory /var/www/server>
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
        
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
<VirtualHost *:80>
   Redirect permanent / https://${domain}
</VirtualHost>
EOF
