#!/bin/bash

# 等待主从服务器启动
sleep 30

# 在主服务器上创建复制用户
docker exec percona-master mysql -uroot -prootpassword \
  -e "CREATE USER 'repl'@'%' IDENTIFIED BY 'replpass';" \
  -e "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';" \
  -e "FLUSH PRIVILEGES;"

# 获取主服务器状态
MASTER_STATUS=$(docker exec percona-master mysql -uroot -prootpassword \
  -e "SHOW MASTER STATUS\G")
CURRENT_LOG=$(echo "$MASTER_STATUS" | grep File | awk '{print $2}')
CURRENT_POS=$(echo "$MASTER_STATUS" | grep Position | awk '{print $2}')

# 配置从服务器复制
docker exec percona-slave mysql -uroot -prootpassword \
  -e "CHANGE MASTER TO MASTER_HOST='percona-master', \
      MASTER_USER='repl', \
      MASTER_PASSWORD='replpass', \
      MASTER_LOG_FILE='$CURRENT_LOG', \
      MASTER_LOG_POS=$CURRENT_POS;"

# 启动从服务器复制
docker exec percona-slave mysql -uroot -prootpassword -e "START SLAVE;" 