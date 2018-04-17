# alpine PHP env

基于alpine的微型php docker环境，php 是 `7.1.x`, 包含最新版本swoole。构建完成的镜像只有30-40多M

共有几个镜像

- `alphp/alphp:base` 基础镜像，后几个镜像基于它。(含有php和一些通用的扩展)
- `alphp/alphp:cli` php cli环境镜像，含有swoole 2 和 mongodb 扩展
- `alphp/alphp:fpm` 在 `alphp/alphp:cli` 的基础上，含有 nginx php-fpm
- `alphp/alphp:dev` 在 `alphp/alphp:cli` 的基础上，含有 nginx php-fpm 并额外包含一些常用工具：vim wget git zip telnet ab 等

## 直接拉取

```bash
docker pull alphp/alphp:base
```

```bash
docker pull alphp/alphp:cli
docker pull alphp/alphp:fpm
docker pull alphp/alphp:dev
```

## 本地构建

### 构建基础镜像

```bash
docker build . -f alphp-base.Dockerfile -t alphp/alphp:base
```

### 构建功能镜像

- 构建 `alphp/alphp:cli`

```bash
docker build . -f alphp-cli.Dockerfile -t alphp/alphp:cli
```

- 构建 `alphp/alphp:fpm`

```bash
// 在alphp/alphp:cli 的基础上，含有 nginx php-fpm
docker build . -f alphp-fpm.Dockerfile -t alphp/alphp:fpm
```

- 构建 `alphp/alphp:dev`

```bash
// 在 alphp/alphp:cli 的基础上，含有 nginx php-fpm 额外包含一些常用工具：vim wget git zip telnet ab 等
docker build . -f alphp-dev.Dockerfile -t alphp/alphp:dev
```

## 一些有用的

### 镜像中的一些信息

- php execute file: `/usr/bin/php`
- php ini file: `/etc/php7/php.ini`
- 扩展配置目录：`/etc/php7/conf.d`
- 扩展编译目录：`/usr/lib/php7/modules`
- php-fpm execute file: `/usr/bin/php-fpm`
- php-fpm conf: `/etc/php7/php-fpm.conf`

### 重新生成 composer autoload

```
composer up nothing
```

### 额外的php扩展

```
memcache
memcached
redis
gearman -- 队列任务处理
seaslog -- 日志扩展
swoole -- 异步事件扩展
xhprof -- 性能分析
xdebug -- 调试工具
yac -- 快速的用户数据共享内存缓存
yar -- 快速并发的rpc
msgpack  -- MessagePack 数据格式实现
yaconf  -- 持久配置容器(php7+)
```

## 工具推荐

### 工具列表

- composer 包管理
- phpunit 单元测试
- phpmd 代码检查
- 类参考文档生成
- [deployer](https://deployer.org/releases/v4.0.1/deployer.phar) 一个用PHP编写的部署工具支持流行的框架
- [xhprof 安装](install-xhprof.md)

### add composer

```
ADD tools/composer.phar /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer
```

## 类参考文档生成

- 使用 sami（推荐）

```bash
$ ./vendor/bin/sami.phar -V
```

生成：

```bash
$ php ./vendor/bin/sami.phar update build/sami.conf.php
```

分开执行：

```bash
// The parse command parses a project and generates a database
$ php ./vendor/bin/sami.phar parse config/symfony.php

// The render command renders a project as a static set of HTML files
$ php ./vendor/bin/sami.phar render config/symfony.php
```

- 使用 apigen

```bash
$ ./vendor/bin/apigen.phar -V
$ ./vendor/bin/apigen.phar generate --help
$ ./vendor/bin/apigen.phar generate -s {source code dir} -d {doc generate dir}
```

- 使用phpDocumentor

```bash
$ ./vendor/bin/phpDocumentor.phar -V
phpDocumentor version v2.9.0
$ ./vendor/bin/phpDocumentor.phar run -d {source code dir} -t {doc generate dir}
```

### 手动管理 php-fpm

```bash
#关闭php-fpm
kill -INT `cat /usr/local/php/var/run/php-fpm.pid`

#重启php-fpm
kill -USR2 `cat /usr/local/php/var/run/php-fpm.pid`
```

### 端口检查 lsof

```
apt-get install lsof
```

### ab 压力测试

安装

```
// ubuntu
apt-get install apache2-utils
// centos
yum install httpd-tools
```

## 安装 swoole

官网 swoole.com
安装相关扩展 redis, zip, mbstring, inotify, pdo_mysql

### 相关库

- [hiredis](https://github.com/redis/hiredis) 异步redis操作支持
- [nghttp2](https://github.com/tatsuhiro-t/nghttp2) http2支持

### 编译命令

```bash
# phpize
# ./configure --enable-swoole-debug --enable-async-redis --enable-openssl --enable-sockets --enable-coroutine --with-php-config=/usr/local/bin/php-config
# make clean
# make -j
# make install
```

### 更多选项说明

使用 `./configure -h` 可以看到全部的选项

- `--enable-swoole-debug`  // 打开调试日志，开启此选项后swoole将打印各类细节的调试日志。生产环境不要启用。
- `--enable-sockets`       // 增加对sockets资源的支持，依赖sockets扩展
- `--enable-async-redis`   // 增加异步Redis客户端支持， 依赖hiredis库
- `--enable-openssl`       // 启用SSL支持,依赖openssl库
- `--enable-http2`         // 增加对HTTP2的支持，依赖nghttp2库. 必须开启openssl
- `--enable-coroutine`       // 启用协程能力


## 库推荐

- [workerman](https://github.com/walkor/workerman)
- [workerman-statistics](https://github.com/walkor/workerman-statistics)
- [swoole](https://github.com/swoole/swoole-src)

### solariumphp/solarium

[solariumphp/solarium](https://github.com/solariumphp/solarium)

搜索引擎solr的php客户端

### elastic/elasticsearch-php

[elastic/elasticsearch-php](https://github.com/elastic/elasticsearch-php)

搜索引擎elasticsearch的官方php客户端

## 工具

