# Alpine PHP Docker

[![Docker Build Status](https://img.shields.io/docker/build/swoft/alphp.svg)](https://hub.docker.com/r/swoft/alphp/)
[![Docker Pulls](https://img.shields.io/docker/pulls/swoft/alphp.svg)](https://hub.docker.com/r/swoft/alphp/)
[![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/swoft/alphp/cli.svg)](https://hub.docker.com/r/swoft/alphp/)
[![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/swoft/alphp/cli.svg)](https://hub.docker.com/r/swoft/alphp/tags/)

`alphp` - 基于alpine的微型php docker环境，php 是 `7.x`, 包含最新版本swoole。构建完成的镜像只有30-40M

共有几个镜像

- `swoft/alphp:base` 基础镜像，后几个镜像基于它。(含有php和一些通用的扩展)
- `swoft/alphp:cli` php cli环境镜像，含有swoole 和 mongodb 扩展
- `swoft/alphp:fpm` 在 `swoft/alphp:cli` 的基础上，含有 nginx php-fpm
- `swoft/alphp:dev` 在 `swoft/alphp:cli` 的基础上，含有 nginx php-fpm 以及一些常用工具：vim wget git zip telnet ab 等

## Dockerfile links

base on **alpine 3.8**(php 7.2.x):

- base [alphp-base.Dockerfile](https://github.com/swoft-cloud/alphp/blob/master/alphp-base.Dockerfile)
[![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/swoft/alphp/base.svg)](https://hub.docker.com/r/swoft/alphp/tags/)
[![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/swoft/alphp/base.svg)](https://hub.docker.com/r/swoft/alphp/)
- cli [alphp-cli.Dockerfile](https://github.com/swoft-cloud/alphp/blob/master/alphp-cli.Dockerfile) 
[![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/swoft/alphp/cli.svg)](https://hub.docker.com/r/swoft/alphp/tags/)
[![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/swoft/alphp/cli.svg)](https://hub.docker.com/r/swoft/alphp/)
- fpm [alphp-fpm.Dockerfile](https://github.com/swoft-cloud/alphp/blob/master/alphp-fpm.Dockerfile)
[![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/swoft/alphp/fpm.svg)](https://hub.docker.com/r/swoft/alphp/tags/)
[![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/swoft/alphp/fpm.svg)](https://hub.docker.com/r/swoft/alphp/)
- dev [alphp-dev.Dockerfile](https://github.com/swoft-cloud/alphp/blob/master/alphp-dev.Dockerfile)
[![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/swoft/alphp/dev.svg)](https://hub.docker.com/r/swoft/alphp/tags/)
[![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/swoft/alphp/dev.svg)](https://hub.docker.com/r/swoft/alphp/)

---

base on **alpine 3.7**(php 7.1.x):

- base-3.7([alphp-base.Dockerfile](https://github.com/swoft-cloud/alphp/blob/alpine3.7/alphp-base.Dockerfile))
- cli-3.7([alphp-cli.Dockerfile](https://github.com/swoft-cloud/alphp/blob/alpine3.7/alphp-cli.Dockerfile))
- fpm-3.7([alphp-fpm.Dockerfile](https://github.com/swoft-cloud/alphp/blob/alpine3.7/alphp-fpm.Dockerfile))
- dev-3.7([alphp-dev.Dockerfile](https://github.com/swoft-cloud/alphp/blob/alpine3.7/alphp-dev.Dockerfile))

---

base on **alpine 3.8**(php 7.2.x):

- base-3.8([alphp-base.Dockerfile](https://github.com/swoft-cloud/alphp/blob/alpine3.8/alphp-base.Dockerfile))
- cli-3.8([alphp-cli.Dockerfile](https://github.com/swoft-cloud/alphp/blob/alpine3.8/alphp-cli.Dockerfile))
- fpm-3.8([alphp-fpm.Dockerfile](https://github.com/swoft-cloud/alphp/blob/alpine3.8/alphp-fpm.Dockerfile))
- dev-3.8([alphp-dev.Dockerfile](https://github.com/swoft-cloud/alphp/blob/alpine3.8/alphp-dev.Dockerfile))

[dchub-link]: https://hub.docker.com/r/swoft/alphp/ "alphp on hub.docker"
[dchub-tags]: https://hub.docker.com/r/swoft/alphp/tags/ "alphp tag list"

## 直接拉取

```bash
docker pull swoft/alphp:base
```

```bash
docker pull swoft/alphp:cli
docker pull swoft/alphp:fpm
docker pull swoft/alphp:dev
```

> hub.docker 地址： https://hub.docker.com/r/swoft/alphp/

## 本地构建

### 构建基础镜像

```bash
docker build . -f alphp-base.Dockerfile -t swoft/alphp:base
```

### 构建功能镜像

- 构建 `swoft/alphp:cli`

```bash
docker build . -f alphp-cli.Dockerfile -t swoft/alphp:cli
```

- 构建 `swoft/alphp:fpm`

```bash
// 在swoft/alphp:cli 的基础上，含有 nginx php-fpm
docker build . -f alphp-fpm.Dockerfile -t swoft/alphp:fpm
```

- 构建 `swoft/alphp:dev`

```bash
// 在 swoft/alphp:cli 的基础上，含有 nginx php-fpm 额外包含一些常用工具：vim wget git zip telnet ab 等
docker build . -f alphp-dev.Dockerfile -t swoft/alphp:dev
```

## 一些有用的

### 更改软件源

```text
sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/' /etc/apk/repositories
```

### Dockerfile注意

- 如果想要主进程接收 `docker stop` 信号(`SIGTERM`)，一定要用 `ENTRYPOINT` 或者 `RUN` 来启动运行主进程，不能使用 CMD。

> CMD 会始终使用 sh -c command 来执行命令，这样PID = 1 的就不是真实命令所在进程了

```dockerfile
ENTRYPOINT ["php", "/var/www/bin/cli", "taskServer:restart"]
```

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
- ~`--enable-coroutine`~     // 启用协程能力(swoole 4 已去除此选项)

## 库推荐

- [workerman](https://github.com/walkor/workerman)
- [swoole](https://github.com/swoole/swoole-src)
