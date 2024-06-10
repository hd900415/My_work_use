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
-v /var/log/nacos/:/home/nacos/logs \
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
-v /var/log/nacos/:/home/nacos/logs \
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
-v /var/log/nacos/:/home/nacos/logs \
--restart=always \
--name nacos2 \
nacos/nacos-server:v2.2.3