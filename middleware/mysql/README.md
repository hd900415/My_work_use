# 如何使用Docker 构建Mysql 主从复制架构
## 分别使用my_master.cnf 和my_slave.cnf 作为主库和从库的配置文件
#### 其中注意Bin-Log设置的不同

server-id = 1 主库的序号小于从库
binlog-ignore-db=mysql
binlog-ignore-db=information_schema
# 数据库名称（主从复制）
binlog-do-db=zhijia ### 这里设置数据库
#开启bin log 功能
log-bin=mysql-bin
#binlog 记录内容的方式，记录被操作的每一行
binlog_format = ROW
#对于binlog_format = ROW模式时，FULL模式可以用于误操作后的flashBack。
#如果设置为MINIMAL，则会减少记录日志的内容，只记录受影响的列，但对于部分update无法flashBack
binlog_row_image = FULL
#bin log日志保存的天数
#
创建复制的用户或者使用root用户

CREATE USER 'replicator'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
FLUSH PRIVILEGES;

### MySQL 部署成功后，进行配置。
# 在从库进行配置
STOP SLAVE;
CHANGE MASTER TO
MASTER_HOST='主服务器的IP地址',
MASTER_USER='replicator',
MASTER_PASSWORD='replicatorpassword',
MASTER_LOG_FILE='mysql-bin.000001',  # 从之前SHOW MASTER STATUS获取的日志文件名
MASTER_LOG_POS=154;  # 从之前SHOW MASTER STATUS获取的位置
START SLAVE;

#

SHOW SLAVE STATUS\G;  查看 从库状态
SHOW MASTER STATUS;