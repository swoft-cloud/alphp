# @description php 7.1 image base on the alpine 3.7 镜像更小
#                       some information
# ------------------------------------------------------------------------------------
# @link https://hub.docker.com/_/alpine/      alpine image
# @link https://hub.docker.com/_/php/         php image
# @link https://github.com/docker-library/php php dockerfiles
# ------------------------------------------------------------------------------------
# @build-example docker build . -f alphp-base.Dockerfile -t swoft/alphp:base
#

FROM alpine:3.8
LABEL maintainer="inhere <cloud798@126.com>" version="1.0"

##
# ---------- env settings ----------
##

# --build-arg timezone=Asia/Shanghai
ARG timezone
# prod pre test dev
ARG app_env=prod
# default use www-data user
ARG add_user=www-data

ENV APP_ENV=${app_env:-"prod"} \
    TIMEZONE=${timezone:-"Asia/Shanghai"}

##
# ---------- building ----------
##

RUN set -ex \
        # change apk source repo
        && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/' /etc/apk/repositories \
        && apk update \
        && apk add --no-cache \
        # Install base packages ('ca-certificates' will install 'nghttp2-libs')
        ca-certificates \
        curl \
        tar \
        xz \
        libressl \
        # openssh  \
        # openssl  \
        tzdata \
        pcre \
        # install php7 and some extensions
        php7 \
        # php7-common \
        php7-bcmath \
        php7-curl \
        php7-ctype \
        php7-dom \
        php7-fileinfo \
        # php7-gettext \
        php7-iconv \
        php7-json \
        php7-mbstring \
        php7-mysqlnd \
        php7-openssl \
        # php7-opcache \
        php7-pdo \
        php7-pdo_mysql \
        php7-pdo_sqlite \
        php7-phar \
        php7-posix \
        php7-redis \
        php7-simplexml \
        php7-sockets \
        php7-sodium \
        # php7-sqlite \
        php7-session \
        php7-sysvshm \
        php7-sysvmsg \
        php7-sysvsem \
        php7-tokenizer \
        php7-zip \
        php7-zlib \
        && apk del --purge *-dev \
        && rm -rf /var/cache/apk/* /tmp/* /usr/share/man /usr/share/php7 \
        #  ---------- some config,clear work ----------
        && cd /etc/php7 \
        # - config PHP
        && { \
            echo "upload_max_filesize=100M"; \
            echo "post_max_size=108M"; \
            echo "memory_limit=1024M"; \
            echo "date.timezone=${TIMEZONE}"; \
        } | tee conf.d/99-overrides.ini \
        # - config timezone
        && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
        && echo "${TIMEZONE}" > /etc/timezone \
        # ---------- some config work ----------
        # - ensure 'www-data' user exists(82 is the standard uid/gid for "www-data" in Alpine)
        && addgroup -g 82 -S ${add_user} \
        && adduser -u 82 -D -S -G ${add_user} ${add_user} \
        # - create user dir
        && mkdir -p /data \
        && chown -R ${add_user}:${add_user} /data \
        && echo -e "\033[42;37m Build Completed :).\033[0m\n"

# EXPOSE 9000
VOLUME ["/var/www", "/data"]
WORKDIR /var/www
