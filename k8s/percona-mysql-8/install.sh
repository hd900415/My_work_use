#!/bin/bash

# 定义变量
MASTER_IP="your_master_ip"  # 请替换为实际的主服务器IP
SLAVE_IP="your_slave_ip"    # 请替换为实际的从服务器IP
MYSQL_ROOT_PASSWORD="rootpassword"
MYSQL_DATABASE="mydb"
MYSQL_USER="myuser"
MYSQL_PASSWORD="mypassword"
REPL_USER="repl"
REPL_PASSWORD="replpass"

# 在主服务器上执行的命令
setup_master() {
    echo "正在配置主服务器..."
    
    # 创建主服务器配置目录
    mkdir -p /etc/my.cnf.d/
    mkdir -p /data/mysql/master
    
    # 创建主服务器配置文件
    cat > /etc/my.cnf.d/master.cnf << 'EOF'
[mysqld]
# 基本配置
server-id=1
log-bin=mysql-bin
binlog_format=ROW
gtid_mode=ON
enforce-gtid-consistency=ON

# 内存配置
innodb_buffer_pool_size=4G
innodb_buffer_pool_instances=4
innodb_log_buffer_size=16M
max_connections=2000
thread_cache_size=128

# InnoDB优化
innodb_file_per_table=1
innodb_flush_log_at_trx_commit=1
innodb_flush_method=O_DIRECT
innodb_read_io_threads=8
innodb_write_io_threads=8
innodb_io_capacity=2000
innodb_io_capacity_max=4000

# 二进制日志配置
sync_binlog=1
binlog_cache_size=4M
max_binlog_cache_size=2G
max_binlog_size=1G
expire_logs_days=7

# 临时表和缓存
tmp_table_size=64M
max_heap_table_size=64M
table_open_cache=4096
table_definition_cache=4096

# 其他优化
sort_buffer_size=8M
read_buffer_size=4M
read_rnd_buffer_size=8M
join_buffer_size=8M
EOF
    
    # 启动主服务器容器
    docker run -d \
        --name percona-master \
        -p 3306:3306 \
        -v /data/mysql/master:/var/lib/mysql \
        -v /etc/my.cnf.d/master.cnf:/etc/my.cnf.d/master.cnf \
        -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
        -e MYSQL_DATABASE=${MYSQL_DATABASE} \
        -e MYSQL_USER=${MYSQL_USER} \
        -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
        percona:8.0

    # 等待MySQL启动
    echo "等待MySQL启动..."
    sleep 30

    # 创建复制用户
    docker exec percona-master mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
        -e "CREATE USER '${REPL_USER}'@'%' IDENTIFIED BY '${REPL_PASSWORD}';" \
        -e "GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'%';" \
        -e "FLUSH PRIVILEGES;"

    # 获取主服务器状态
    docker exec percona-master mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
        -e "SHOW MASTER STATUS\G" > master_status.txt
}

# 在从服务器上执行的命令
setup_slave() {
    echo "正在配置从服务器..."
    
    # 创建从服务器配置目录
    mkdir -p /etc/my.cnf.d/
    mkdir -p /data/mysql/slave
    
    # 创建从服务器配置文件
    cat > /etc/my.cnf.d/slave.cnf << 'EOF'
[mysqld]
# 基本配置
server-id=2
gtid_mode=ON
enforce-gtid-consistency=ON

# 内存配置
innodb_buffer_pool_size=4G
innodb_buffer_pool_instances=4
innodb_log_buffer_size=16M
max_connections=2000
thread_cache_size=128

# InnoDB优化
innodb_file_per_table=1
innodb_flush_log_at_trx_commit=2
innodb_flush_method=O_DIRECT
innodb_read_io_threads=8
innodb_write_io_threads=8
innodb_io_capacity=2000
innodb_io_capacity_max=4000

# 复制相关配置
slave_parallel_type=LOGICAL_CLOCK
slave_parallel_workers=8
master_info_repository=TABLE
relay_log_info_repository=TABLE
relay_log_recovery=ON
sync_relay_log=0
sync_relay_log_info=0

# 临时表和缓存
tmp_table_size=64M
max_heap_table_size=64M
table_open_cache=4096
table_definition_cache=4096

# 其他优化
sort_buffer_size=8M
read_buffer_size=4M
read_rnd_buffer_size=8M
join_buffer_size=8M

# 从库特定优化
read_only=ON
skip_slave_start=ON
log_slave_updates=ON
EOF
    
    # 启动从服务器容器
    docker run -d \
        --name percona-slave \
        -p 3306:3306 \
        -v /data/mysql/slave:/var/lib/mysql \
        -v /etc/my.cnf.d/slave.cnf:/etc/my.cnf.d/slave.cnf \
        -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
        -e MYSQL_DATABASE=${MYSQL_DATABASE} \
        -e MYSQL_USER=${MYSQL_USER} \
        -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
        percona:8.0

    # 等待MySQL启动
    echo "等待MySQL启动..."
    sleep 30
}

# 配置主从同步
configure_replication() {
    echo "正在配置主从同步..."
    
    # 获取主服务器日志文件和位置
    MASTER_LOG_FILE=$(grep "File:" master_status.txt | awk '{print $2}')
    MASTER_LOG_POS=$(grep "Position:" master_status.txt | awk '{print $2}')
    
    # 配置从服务器复制
    docker exec percona-slave mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
        -e "CHANGE MASTER TO \
            MASTER_HOST='${MASTER_IP}', \
            MASTER_USER='${REPL_USER}', \
            MASTER_PASSWORD='${REPL_PASSWORD}', \
            MASTER_LOG_FILE='${MASTER_LOG_FILE}', \
            MASTER_LOG_POS=${MASTER_LOG_POS};"
    
    # 启动从服务器复制
    docker exec percona-slave mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
        -e "START SLAVE;"
}

# 验证主从同步状态
check_replication_status() {
    echo "检查主从同步状态..."
    docker exec percona-slave mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
        -e "SHOW SLAVE STATUS\G"
}

# 数据迁移函数（如果需要从现有MySQL迁移数据）
migrate_data() {
    if [ -n "$1" ]; then
        OLD_MYSQL_HOST=$1
        echo "从 ${OLD_MYSQL_HOST} 迁移数据..."
        
        # 导出原数据库
        mysqldump -h ${OLD_MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} \
            --single-transaction \
            --master-data=2 \
            --routines \
            --triggers \
            --events \
            ${MYSQL_DATABASE} > backup.sql
        
        # 导入到新主服务器
        docker exec -i percona-master mysql -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} < backup.sql
    fi
}

# 主函数
main() {
    # 检查是否为主服务器
    if [ "$(hostname -I | awk '{print $1}')" = "${MASTER_IP}" ]; then
        echo "在主服务器上执行安装..."
        setup_master
        
        # 如果需要迁移数据，取消注释下面的行并提供源MySQL主机
        # migrate_data "source_mysql_host"
        
    elif [ "$(hostname -I | awk '{print $1}')" = "${SLAVE_IP}" ]; then
        echo "在从服务器上执行安装..."
        setup_slave
        configure_replication
        check_replication_status
    else
        echo "错误：当前服务器IP不匹配配置的主从IP"
        exit 1
    fi
}

# 执行主函数
main

echo "安装完成！"

#