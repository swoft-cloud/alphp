# @description php 7.1 image base on the alpine 3.7 镜像更小. 本镜像用于开发，所以安装了常用工具
#                       some information
# ------------------------------------------------------------------------------------
# @link https://hub.docker.com/_/alpine/      alpine image
# @link https://hub.docker.com/_/php/         php image
# @link https://github.com/docker-library/php php dockerfiles
# ------------------------------------------------------------------------------------
# @build-example docker build . -f alphp-dev.Dockerfile -t alphp:dev
#

FROM alphp:cli as builder


FROM alphp:base
LABEL maintainer="inhere <cloud798@126.com>" version="1.0"

WORKDIR /usr/lib/php7/modules

COPY --from=builder /usr/local/lib/libhiredis.so.0.13 /usr/local/lib/libhiredis.so.0.13
COPY --from=builder /usr/lib/php7/modules/mongodb.so mongodb.so
# COPY --from=builder /usr/lib/php7/modules/phalcon.so phalcon.so
COPY --from=builder /usr/lib/php7/modules/swoole.so swoole.so

WORKDIR /var/www

RUN set -ex \
        && echo "extension=mongodb.so" > /etc/php7/conf.d/20_mongodb.ini  \
        # && echo "extension=phalcon.so" > /etc/php7/conf.d/20_phalcon.ini \
        && echo "extension=swoole.so" > /etc/php7/conf.d/20_swoole.ini \
        && php -m \
        # install some tools
        && apk update \
        && apk add --no-cache nginx php7-fpm vim wget net-tools git zip unzip apache2-utils \
        && apk del --purge *-dev \
        && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
        # && rm /etc/nginx/conf.d/default.conf /etc/nginx/nginx.conf \
        # config site
        && chown -R www:www /var/www \
        && { \
            echo "#!/bin/sh"; \
            echo "nginx -g 'daemon off;'"; \
            # echo "php /var/www/uem.phar taskServer:start -d"; \
            echo "php-fpm7 -F"; \
        } | tee /run.sh \
        && chmod 755 /run.sh

VOLUME ["/var/www", "/data"]

EXPOSE 9501 9502 80

# COPY docker/config/nginx.conf /etc/nginx/nginx.conf
# COPY docker/config/app-vhost.conf /etc/nginx/conf.d/app-vhost.conf

CMD /run.sh
