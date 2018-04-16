FROM php:7.1-fpm
# php fpm 7.2 used system is debain 9
# always use latest version php

LABEL maintainer="inhere <cloud798@126.com>" version="1.0"

ARG timezone
# ARG fpmport

ENV TIMEZONE=$timezone
ENV HIREDIS_VERSION=0.13.3

# 更换(debian 8)软件源
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
ADD data/resources/debian8.sources /etc/apt/sources.list

RUN uname -a && php -v && apt-get update

# Now,Install basic tool
# apache2-utils 包含 ab 压力测试工具
# net-tools 包含 netstat工具
RUN apt-get install -y \
    openssl pkg-config \
    vim wget net-tools curl lsof telnet git zip unzip apache2-utils

##
# Install core extensions for php
##
#
# bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv
# imap interbase intl json ldap mbstring mcrypt mssql mysql mysqli oci8 odbc opcache pcntl
# pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix
# pspell readline recode reflection session shmop simplexml snmp soap sockets spl standard
# sybase_ct sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zip
#
# Must install dependencies for your extensions manually, if need. libpng12-dev
RUN apt-get install -y \
    libfreetype6-dev zlib1g-dev zlib1g libjpeg62-turbo-dev libmcrypt-dev libpng-dev \
    && docker-php-ext-install -j$(nproc) mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# no dependency extension
RUN docker-php-ext-install gettext mysqli opcache pdo_mysql sockets pcntl zip sysvmsg sysvsem sysvshm

# update pecl
RUN pecl update-channels

##
# Install PECL extensions: memcached
##
RUN apt-get install -y libmemcached-dev && pecl install memcached && docker-php-ext-enable memcached

##
# Install PECL extensions: mongodb 扩展，需要 libssl-dev pkg-config
##
RUN apt-get install -y libssl-dev && pecl install mongodb && docker-php-ext-enable mongodb

# gearman 此php扩展不支持 php7
# libgearman-dev  && pecl install gearman && docker-php-ext-enable gearman

# 日志扩展
# RUN pecl install seaslog && docker-php-ext-enable seaslog
# 调试扩展
RUN pecl install xdebug && docker-php-ext-enable xdebug
# trace调试扩展
# RUN pecl install trace-1.0.0 && docker-php-ext-enable trace
# redis缓存扩展
RUN pecl install redis && docker-php-ext-enable redis

RUN pecl install msgpack && docker-php-ext-enable msgpack
# RUN pecl install yac && docker-php-ext-enable yac
# RUN pecl install yar && docker-php-ext-enable yar
# RUN pecl install yaconf && docker-php-ext-enable yaconf

# 文件变动监控扩展
RUN pecl install inotify && docker-php-ext-enable inotify
# xhprof 与swoole有冲突
# RUN pecl install xhprof && docker-php-ext-enable xhprof
# RUN pecl install channel://pecl.php.net/xhprof-0.9.4 && docker-php-ext-enable xhprof

# hiredis - redis C client, provide async operate redis support
RUN cd /tmp \
    # && curl -o hiredis-${HIREDIS_VERSION}.tar.gz https://github.com/redis/hiredis/archive/v${HIREDIS_VERSION}.tar.gz \
    && wget -O hiredis-${HIREDIS_VERSION}.tar.gz -c https://github.com/redis/hiredis/archive/v${HIREDIS_VERSION}.tar.gz \
    && tar -zxvf hiredis-${HIREDIS_VERSION}.tar.gz && cd hiredis-${HIREDIS_VERSION} && make -j && make install && ldconfig

##
# Swoole extension
# 异步事件扩展
##
# RUN pecl install swoole && docker-php-ext-enable swoole
RUN wget https://github.com/swoole/swoole-src/archive/v2.0.10-stable.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
        cd swoole \
        && phpize \
        && ./configure --enable-async-redis --enable-mysqlnd --enable-coroutine \
        && make -j$(nproc) && make install \
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole

# Other extensions
# RUN curl -fsSL 'https://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz' -o xcache.tar.gz \
#     && mkdir -p xcache \
#     && tar -xf xcache.tar.gz -C xcache --strip-components=1 \
#     && rm xcache.tar.gz \
#     && ( \
#         cd xcache \
#         && phpize && ./configure --enable-xcache \
#         && make -j$(nproc) && make install \
#     ) \
#     && rm -r xcache \
#     && docker-php-ext-enable xcache

##
# Basic config
# 1. change Timezone
# 2. open some command alias
##
RUN echo "${TIMEZONE}" > /etc/timezone \
  && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
  && sed -i 's/^# alias/alias/g' ~/.bashrc

##
# PHP Configuration
# Override configurtion
##
# COPY data/resources/php/php-seaslog.ini /usr/local/etc/php/conf.d/docker-php-ext-seaslog.ini
COPY data/resources/php/php-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY data/resources/php/php-ini-overrides.ini /usr/local/etc/php/conf.d/99-overrides.ini
RUN echo "date.timezone=$TIMEZONE" >> /usr/local/etc/php/conf.d/99-overrides.ini \
  && echo "yaconf.directory=/tmp/yaconf" >> /usr/local/etc/php/conf.d/docker-php-ext-yaconf.ini

##
# PHP-FPM Configuration
##
# add php-fpm to service
COPY data/resources/php/init.d.php-fpm /etc/init.d/php-fpm
# open php-fpm pid file listen = 127.0.0.1:9000
RUN sed -i '/^;pid\s*=\s*/s/\;//g' /usr/local/etc/php-fpm.conf \
    && chmod +x /etc/init.d/php-fpm
    # && chkconfig --add php-fpm

# Clear temp files
RUN docker-php-source delete \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && echo -e "\033[42;37m PHP letest installed.\033[0m"

# Install composer
ADD data/packages/php-composer/composer.phar /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer

WORKDIR "/var/www"

################################################################################
# Volumes
################################################################################

VOLUME /var/www /var/log/php7


# extends from parent
# EXPOSE 9000
# CMD ["php-fpm"]
