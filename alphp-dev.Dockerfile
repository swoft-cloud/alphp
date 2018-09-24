# @description php 7.1 image base on the alpine 3.7 镜像更小. 本镜像用于开发，所以安装了常用工具
#                       some information
# ------------------------------------------------------------------------------------
# @link https://hub.docker.com/_/alpine/      alpine image
# @link https://hub.docker.com/_/php/         php image
# @link https://github.com/docker-library/php php dockerfiles
# ------------------------------------------------------------------------------------
# @build-example docker build . -f alphp-dev.Dockerfile -t swoft/alphp:dev
#

FROM swoft/alphp:cli
LABEL maintainer="inhere <cloud798@126.com>" version="1.0"

WORKDIR /var/www

RUN set -ex \
        && php -m \
        # install some tools
        && apk update \
        && apk add --no-cache \
            php7-fpm php7-pcntl \
            nginx vim wget net-tools git zip unzip apache2-utils mysql-client redis \
        && apk del --purge *-dev \
        && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
        # && rm /etc/nginx/conf.d/default.conf /etc/nginx/nginx.conf \
        # install latest composer
        && wget https://getcomposer.org/composer.phar \
        && mv composer.phar /usr/local/bin/composer \
        # - config nginx
        && mkdir /run/nginx \
        # - config PHP-FPM
        && cd /etc/php7 \
        && { \
            echo "[global]"; \
            echo "pid = /var/run/php-fpm.pid"; \
            echo "[www-data]"; \
            echo "user = www-data"; \
            echo "group = www-data"; \
        } | tee php-fpm.d/custom.conf \
        # config site
        && chown -R www-data:www-data /var/www \
        && { \
            echo "#!/bin/sh"; \
            echo "nginx -g 'daemon on;'"; \
            # echo "php /var/www/uem.phar taskServer:start -d"; \
            echo "php-fpm7 -F"; \
        } | tee /run.sh \
        && chmod 755 /run.sh

VOLUME ["/var/www", "/data"]

EXPOSE 9501 80

# COPY docker/config/nginx.conf /etc/nginx/nginx.conf
# COPY docker/config/app-vhost.conf /etc/nginx/conf.d/app-vhost.conf

CMD /run.sh
