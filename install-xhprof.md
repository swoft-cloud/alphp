# 安装xhprof

> from http://www.open-open.com/lib/view/open1453899928714.html

##下载编译安装的命令如下：

```bash
$ wget https://github.com/phacility/xhprof/archive/master.zip
$ unzip ./xhprof_master.zip
$ cd ./xhprof_master/extension
$ /usr/local/php/bin/phpize
$ ./configure --with-php-config=/usr/local/php/bin/php-config
$ make
$ make install
```

## 启用 xhprof 扩展， 检查安装 `php -m`

## 拷贝xhprof相关程序到指定目录:

```bash
$ mkdir -p /www/sites/xhprof
$ cp -r ./xhprof_master/xhprof_html /www/sites/xhprof
$ cp -r ./xhprof_master/xhprof_lib /www/sites/xhprof
```

## 修改nginx配置，以便通过url访问性能数据:

在nginx中增加如下代码：

```
server {
    listen  8999;
    root    /opt/sites/xhprof/;
    index  index.php index.html;
    location ~ .*\.php$ {
        add_header  Cache-Control "no-cache, no-store, max-age=0, must-revalidate";
        add_header  Pragma  no-cache;
        add_header Access-Control-Allow-Origin *;
        add_header      Via "1.0 xgs-150";
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        include fastcgi.conf;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }
}
```
