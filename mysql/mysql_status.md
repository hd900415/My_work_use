MySQL性能分析及工具使用
https://www.cnblogs.com/Courage129/p/14188422.html

performance_schema
https://www.cnblogs.com/antLaddie/p/17101777.html

# MySQL 主从复制配置步骤

## 1. 创建从库配置文件

将以下内容保存为 `slave-my.cnf` 文件：

```plaintext
从库配置文件
```

## 2. 启动从库

将 `slave-my.cnf` 文件复制到 MySQL 配置目录（例如 `/etc/mysql/` 或 `/etc/`），然后启动 MySQL 从库：

```bash
mysqld --defaults-file=/etc/mysql/slave-my.cnf
```

## 3. 配置主从复制

### 3.1 在主库上创建复制用户

登录到主库 MySQL 实例：

```bash
mysql -u root -p
```

执行以下命令创建复制用户：

```sql
CREATE USER 'replication_user'@'%' IDENTIFIED BY 'replication_password';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';
FLUSH PRIVILEGES;
```

### 3.2 查看主库的二进制日志文件位置

在主库 MySQL 实例中执行以下命令：

```sql
SHOW MASTER STATUS;
```

记下 `File` 和 `Position` 字段的值，这些值将在配置从库时使用。

### 3.3 在从库上配置复制

登录到从库 MySQL 实例：

```bash
mysql -u root -p
```

执行以下命令配置主从复制：

```sql
CHANGE MASTER TO
  MASTER_HOST='主库IP地址',
  MASTER_USER='replication_user',
  MASTER_PASSWORD='replication_password',
  MASTER_LOG_FILE='主库二进制日志文件名',
  MASTER_LOG_POS=主库二进制日志位置;
START SLAVE;
```

## 4. 验证复制状态

在从库 MySQL 实例中执行以下命令：

```sql
SHOW SLAVE STATUS\G
```

确保 `Slave_IO_Running` 和 `Slave_SQL_Running` 都显示为 `Yes`。
