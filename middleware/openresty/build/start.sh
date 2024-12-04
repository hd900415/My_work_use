#!/bin/bash 
# 1.构建镜像
PWD=/data/docker/openresty
cd $PWD

# docker build 镜像
docker build -t openresty:1.25.3.1v1 --no-cache .
docker run -d --name nginx -p 80:80 -p 88:88 -p 443:443 \
  --restart always \
  -v /etc/localtime:/etc/localtime \
  -v /data/docker/openresty/conf/:/usr/local/openresty/nginx/conf:ro \
  -v /data/docker/openresty/logs:/usr/local/openresty/nginx/logs \
  -v /data/docker/openresty/www:/var/www/html:ro \
  openresty:1.25.3.1v1 