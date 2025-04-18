
docker run -d --name mysql \
--restart always  \
-p 3306:3306 \
-e MYSQL_ROOT_PASSWORD='sa3dd3SLKJDf' \
-e MYSQL_DATABASE='zhijia' \
-v /etc/localtime:/etc/localtime \
-v /data/docker/mysql/data:/var/lib/mysql \
-v /data/docker/mysql/conf/my.cnf:/etc/mysql/conf.d/my.cnf \
mysql:8.0.35



alter user 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'yCTFRATrtX3GU3';
FLUSH PRIVILEGES;



docker run -d --name mysql8_cash \
    -p 3307:3306 \
    --network ai-work \
    -e MYSQL_DATABASE=nacos \
    -e MYSQL_ROOT_PASSWORD=facai555 \
    -v /data/docker/mysql/data:/var/lib/mysql \
    -v /data/docker/mysql/conf:/etc/mysql/conf.d \
    -e TZ=Asia/Shanghai \
    mysql:8.0.35

#### 设置时区
#### 设置数据库字符集
####
docker run -d --name mysql8_nacos \
    -p 3306:3306 \
    -e MYSQL_DATABASE=nacos \
    -e MYSQL_ROOT_PASSWORD=facai555 \
    -v /data/mysql/data:/var/lib/mysql \
    -v /data/mysql/conf:/etc/mysql/conf.d \
    -e TZ=Asia/Shanghai \
    mysql:8.0.35


docker run -d --name mysql \
--restart always  \
-p 3306:3306 \
-e MYSQL_ROOT_PASSWORD='Dtixn$U@xdljtS$3145DF' \
-e MYSQL_DATABASE='zhijia' \
-v /etc/localtime:/etc/localtime \
-v /data/docker/mysql/data:/var/lib/mysql \
-v /data/docker/mysql/conf/my.cnf:/etc/mysql/conf.d/my.cnf \
mysql:8.0.35




