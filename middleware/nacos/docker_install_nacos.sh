docker run -d \
--network=host \
-e NACOS_AUTH_ENABLE=false \
-e JVM_XMS=128m \
-e JVM_XMX=128m \
-e JVM_XMN=128m \
-e PREFER_HOST_MODE=ip \
-e MODE=cluster \
-e NACOS_SERVER_PORT=8848 \
-e NACOS_SERVERS="172.28.93.234:8848 172.28.116.31:8848 172.28.104.220:8848 " \
-e SPRING_DATASOURCE_PLATFORM=mysql \
-e MYSQL_SERVICE_HOST=172.28.31.179 \
-e MYSQL_SERVICE_PORT=3306 \
-e MYSQL_SERVICE_USER=root \
-e MYSQL_SERVICE_PASSWORD="S5JgsVP6XrwqbS?q" \
-e MYSQL_SERVICE_DB_NAME=nacos_conf \
-e MYSQL_SERVICE_DB_PARAM='characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Dubai' \
-e NACOS_SERVER_IP=172.28.93.234 \
-v /data/docker/nacos/logs:/home/nacos/logs \
-v /data/docker/nacos/conf:/home/nacos/conf \
-v /data/docker/nacos/data:/home/nacos/data \
--restart=always \
--name nacos2 \
nacos/nacos-server:v2.2.3

docker run -d \
--network=host \
-e NACOS_AUTH_ENABLE=false \
-e JVM_XMS=128m \
-e JVM_XMX=128m \
-e JVM_XMN=128m \
-e PREFER_HOST_MODE=ip \
-e MODE=cluster \
-e NACOS_SERVER_PORT=8848 \
-e NACOS_SERVERS="172.28.93.234:8848 172.28.116.31:8848 172.28.104.220:8848 " \
-e SPRING_DATASOURCE_PLATFORM=mysql \
-e MYSQL_SERVICE_HOST=172.28.31.179 \
-e MYSQL_SERVICE_PORT=3306 \
-e MYSQL_SERVICE_USER=root \
-e MYSQL_SERVICE_PASSWORD="S5JgsVP6XrwqbS?q" \
-e MYSQL_SERVICE_DB_NAME=nacos_conf \
-e MYSQL_SERVICE_DB_PARAM='characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Dubai' \
-e NACOS_SERVER_IP=172.28.116.31 \
-v /data/docker/nacos/logs:/home/nacos/logs \
-v /data/docker/nacos/conf:/home/nacos/conf \
-v /data/docker/nacos/data:/home/nacos/data \
--restart=always \
--name nacos2 \
nacos/nacos-server:v2.2.3

docker run -d \
--network=host \
-e NACOS_AUTH_ENABLE=false \
-e JVM_XMS=128m \
-e JVM_XMX=128m \
-e JVM_XMN=128m \
-e PREFER_HOST_MODE=ip \
-e MODE=cluster \
-e NACOS_SERVER_PORT=8848 \
-e NACOS_SERVERS="172.28.93.234:8848 172.28.116.31:8848 172.28.104.220:8848 " \
-e SPRING_DATASOURCE_PLATFORM=mysql \
-e MYSQL_SERVICE_HOST=172.28.31.179 \
-e MYSQL_SERVICE_PORT=3306 \
-e MYSQL_SERVICE_USER=root \
-e MYSQL_SERVICE_PASSWORD="S5JgsVP6XrwqbS?q" \
-e MYSQL_SERVICE_DB_NAME=nacos_conf \
-e MYSQL_SERVICE_DB_PARAM='characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Dubai' \
-e NACOS_SERVER_IP=172.28.104.220 \
-v /data/docker/nacos/logs:/home/nacos/logs \
-v /data/docker/nacos/conf:/home/nacos/conf \
-v /data/docker/nacos/data:/home/nacos/data \
--restart=always \
--name nacos2 \
nacos/nacos-server:v2.2.3




# standalone 
docker run -d \
-p 8848:8848 \
-e NACOS_AUTH_ENABLE=true \
-e NACOS_AUTH_TOKEN_EXPIRE_SECONDS=18000 \
-e NACOS_AUTH_TOKEN=SecretKey012345678901234567890123456789012345678901234567890123456789 \
-e TZ=Asia/Shanghai \
-e nacos.core.auth.enabled=true \
-e nacos.core.auth.plugin.nacos.token.secret.key=VGhpc0lzTXlDdXN0b21TZWNyZXRLZXkwMTIzNDU2Nzg= \
-e nacos.core.auth.server.identity.key=VGhpc0lzTXlDdXN0b21TZWNyZXRLZXkwMTIzNDU2Nzg= \
-e nacos.core.auth.server.identity.value=VGhpc0lzTXlDdXN0b21TZWNyZXRLZXkwMTIzNDU2Nzg= \
-e JVM_XMS=512m \
-e JVM_XMX=512m \
-e JVM_XMN=512m \
-e PREFER_HOST_MODE=ip \
-e MODE=standalone \
-e NACOS_SERVER_PORT=8848 \
-e SPRING_DATASOURCE_PLATFORM=mysql \
-e MYSQL_SERVICE_HOST=192.168.0.2 \
-e MYSQL_SERVICE_PORT=3306 \
-e MYSQL_SERVICE_USER=root \
-e MYSQL_SERVICE_PASSWORD='Dtixn$U@xdljtS$3145DF' \
-e MYSQL_SERVICE_DB_NAME=nacos \
-e MYSQL_SERVICE_DB_PARAM='characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Dubai' \
-e NACOS_SERVER_IP=148.66.10.42 \
-v /data/docker/nacos/logs:/home/nacos/logs \
-v /data/docker/nacos/conf:/home/nacos/conf \
-v /data/docker/nacos/data:/home/nacos/data \
--restart=always \
--name nacos \
nacos/nacos-server:v2.4.0


# 单机非集群安装
# 1.先运行程序，复制配置文件到宿主机
docker run -p 8848:8848 --name nacos -d nacos/nacos-server:v2.3.2
# 2.复制配置文件
docker cp nacos:/home/nacos/conf /data/docker/nacos/
# 3.导入nacos 数据库sql 
 # 位于配置文件目录下：mysql-schema.sql
docker run -d \
-e JVM_XMS=512m \
-e JVM_XMX=512m \
-e JVM_XMN=512m \
-e NACOS_AUTH_ENABLE=false \
-e MODE=standalone \
-e NACOS_SERVER_PORT=8848 \
-e SPRING_DATASOURCE_PLATFORM=mysql \
-e MYSQL_SERVICE_HOST=192.168.0.108 \
-e MYSQL_SERVICE_PORT=3306 \
-e MYSQL_SERVICE_USER=root \
-e MYSQL_SERVICE_PASSWORD="DtixjtS3145DF" \
-e MYSQL_SERVICE_DB_NAME=nacos \
-v /data/docker/nacos/logs:/home/nacos/logs \
-v /data/docker/nacos/conf:/home/nacos/conf \
-v /data/docker/nacos/data:/home/nacos/data \
--restart=always \
--name nacos \
nacos/nacos-server:v2.3.2