FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install apache2 -y 
RUN apt install php php-mysql php-imagick php-xml \
    libapache2-mod-php php-curl \
    php-zip php-gd php-mbstring -y
RUN a2enmod env rewrite dir mime headers setenvif ssl
RUN apt install sudo curl mariadb-client -y
RUN apt install git -y

RUN git clone --depth 1 --branch v31.0.5 https://github.com/nextcloud/server.git /var/www/server && \
    cd /var/www/server && \
    git submodule update --init && \
    chown -R www-data:www-data /var/www/server/

EXPOSE 80 
EXPOSE 443

WORKDIR /

COPY scripts/entrypoint.sh /entrypoint.sh

COPY scripts/config.sh /config.sh

COPY scripts/apacheconfig.sh /apacheconfig.sh

COPY conf.d/99-nextcloud.ini /etc/php/8.3/apache2/conf.d/99-nextcloud.ini

RUN chmod +x /apacheconfig.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /config.sh

ENTRYPOINT ["/entrypoint.sh"]
