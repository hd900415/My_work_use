docker run -d --name mysql_percona \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD='c' \
    -e MYSQL_DATABASE='zhijia' \
    -v /etc/localtime:/etc/localtime \
    -v /data/docker/mysql/data:/var/lib/mysql \
    percona/percona-server:8.0s