FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install apache2 -y 
RUN apt install php php-mysql php-xml \
    libapache2-mod-php php-curl \
    php-zip php-gd php-mbstring -y
RUN a2enmod env rewrite dir mime headers setenvif ssl
RUN apt install mariadb-server sudo -y
RUN apt install git -y
WORKDIR /var/www/

RUN git clone --depth 1 --branch v31.0.5 https://github.com/nextcloud/server.git /var/www/server && \
    cd server && \
    git submodule update --init && \
    chown -R www-data:www-data /var/www/server/

EXPOSE 80
RUN mkdir -p /home/data && chown -R www-data:www-data /home/data

COPY entrypoint.sh /entrypoint.sh

COPY conf.d/000-default.conf /etc/apache2/sites-enabled/000-default.conf

COPY conf.d/99-nextcloud.ini /etc/php/8.3/apache2/conf.d/99-nextcloud.ini

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

