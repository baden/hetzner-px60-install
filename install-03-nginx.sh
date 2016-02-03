#!/bin/sh

# As root
#


# lsb_release -cs
curl http://nginx.org/keys/nginx_signing.key | apt-key add -
# Stable
# echo -e "deb http://nginx.org/packages/ubuntu/ `lsb_release -cs` nginx\ndeb-src http://nginx.org/packages/ubuntu/ `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
# Mainline
echo -e "deb http://nginx.org/packages/mainline/ubuntu/ `lsb_release -cs` nginx\ndeb-src http://nginx.org/packages/mainline/ubuntu/ `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

apt-get update
apt-get install nginx

# Странно что версия 1.9 не создает привычных  sites-available и sites-enabled

mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled
mv /etc/nginx/nginx.conf /etc/nginx/nginx_conf_backup
# Добавить после
# include /etc/nginx/conf.d/*.conf;
# include /etc/nginx/sites-enabled/*;
#
# worker_processes 4;
# Так же можно включить
# tcp_nopush on;
# tcp_nodelay on;
# gzip on;
# gzip_disable "msie6";
# gzip_proxied any;
# gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/octet-stream;

# apt-get install -y p7zip-full htop nginx
#
# nginx -s reload

# # пока не понял, возможно еще нужно:
# update-rc.d nginx defaults
