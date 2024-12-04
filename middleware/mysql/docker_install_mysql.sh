
docker run -d --name mysql \
--restart always  \
-p 3306:3306 \
-e MYSQL_ROOT_PASSWORD='Dtixn$U@xdljtS$3145DF' \
-e MYSQL_DATABASE='zhijia' \
-v /etc/localtime:/etc/localtime \
-v /data/docker/mysql/data:/var/lib/mysql \
-v /data/docker/mysql/conf/my.cnf:/etc/mysql/conf.d/my.cnf \
mysql:8.0.35