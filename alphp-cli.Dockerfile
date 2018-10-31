# @description php 7.1 image base on the alpine 3.7 镜像更小，构建完成只有46M
#                       some information
# ------------------------------------------------------------------------------------
# @link https://hub.docker.com/_/alpine/      alpine image
# @link https://hub.docker.com/_/php/         php image
# @link https://github.com/docker-library/php php dockerfiles
# ------------------------------------------------------------------------------------
# @build-example docker build . -f alphp-cli.Dockerfile -t swoft/alphp:cli
#

FROM swoft/alphp:base
LABEL maintainer="inhere <cloud798@126.com>" version="1.0"

##
# ---------- env settings ----------
##

ENV HIREDIS_VERSION=0.14.0 \
    SWOOLE_VERSION=4.2.5 \
    MONGO_VERSION=1.5.2 \
    #  install and remove building packages
    PHPIZE_DEPS="autoconf dpkg-dev dpkg file g++ gcc libc-dev make php7-dev php7-pear pkgconf re2c pcre-dev zlib-dev"

##
# install php extensions
##

# 下载太慢，所以可以先下载好
# COPY deps/hiredis-${HIREDIS_VERSION}.tar.gz hiredis.tar.gz
# COPY deps/swoole-${SWOOLE_VERSION}.tar.gz swoole.tar.gz
# COPY deps/cphalcon-${PHALCON_VERSION}.tar.gz cphalcon.tar.gz
# COPY deps/mongodb-${MONGO_VERSION}.tgz mongodb.tgz
RUN set -ex \
        && cd /tmp \
        # && wget -O hiredis.tar.gz -c https://github.com/redis/hiredis/archive/v${HIREDIS_VERSION}.tar.gz \
        && curl -SL "https://github.com/redis/hiredis/archive/v${HIREDIS_VERSION}.tar.gz" -o hiredis.tar.gz \
        && curl -SL "https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz" -o swoole.tar.gz \
        # && curl -SL "https://github.com/mongodb/mongo-php-driver/archive/v${MONGO_VERSION}.tgz" -o mongodb.tgz \
        && curl -SL "http://pecl.php.net/get/mongodb-${MONGO_VERSION}.tgz" -o mongodb.tgz \
        && ls -alh \
        && apk update \
        # for swoole extension libaio linux-headers
        && apk add --no-cache libstdc++ openssl \
        && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS libaio-dev openssl-dev \
        # php extension: mongodb
        && pecl install mongodb.tgz \
        # && pecl install mongodb \
        && echo "extension=mongodb.so" > /etc/php7/conf.d/20_mongodb.ini \
        # hiredis - redis C client, provide async operate support for Swoole
        && cd /tmp \
        && tar -zxvf hiredis.tar.gz \
        && cd hiredis-${HIREDIS_VERSION} \
        && make -j && make install \
        # php extension: swoole
        && cd /tmp \
        && mkdir -p swoole \
        && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
        && rm swoole.tar.gz \
        && ( \
            cd swoole \
            && phpize \
            && ./configure --enable-async-redis --enable-mysqlnd --enable-openssl \
            && make -j$(nproc) && make install \
        ) \
        && rm -r swoole \
        && echo "extension=swoole.so" > /etc/php7/conf.d/20_swoole.ini \
        && php -v \
        # ---------- clear works ----------
        && apk del .build-deps \
        && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
        && echo -e "\033[42;37m Build Completed :).\033[0m\n"

EXPOSE 9501

WORKDIR /var/www
