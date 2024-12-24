
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