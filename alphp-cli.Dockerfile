# @description php image base on the alpine edge 镜像更小
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

ENV SWOOLE_VERSION=4.3.2 \
    #  install and remove building packages
    PHPIZE_DEPS="autoconf dpkg-dev dpkg file g++ gcc libc-dev make php7-dev php7-pear pkgconf re2c pcre-dev zlib-dev"

##
# install php extensions
##

# 若下载太慢，所以也可以先下载好
# COPY deps/swoole-${SWOOLE_VERSION}.tar.gz swoole.tar.gz
RUN set -ex \
        && apk update \
        # libs for swoole extension. libaio linux-headers
        && apk add --no-cache libstdc++ openssl \
        && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS libaio-dev openssl-dev \
        # php extension: swoole
        && cd /tmp \
        && curl -SL "https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz" -o swoole.tar.gz \
        && mkdir -p swoole \
        && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
        && rm swoole.tar.gz \
        && ( \
            cd swoole \
            && phpize \
            && ./configure --enable-mysqlnd --enable-openssl \
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
