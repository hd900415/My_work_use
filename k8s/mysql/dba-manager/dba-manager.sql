-- 查看当前连接
SHOW PROCESSLIST;

-- 查看当前连接数
SHOW STATUS WHERE `variable_name` = 'Threads_connected';

-- 查看负载
SHOW STATUS WHERE `variable_name` = 'Threads_running';

-- 查看CPU使用率
SHOW STATUS WHERE `variable_name` LIKE '%cpu_usage%';

-- 查看InnoDB缓冲池使用情况
SHOW ENGINE INNODB STATUS;

-- 查看慢查询日志
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'slow_query_log_file';
SHOW VARIABLES LIKE 'long_query_time';

-- 查看查询缓存使用情况
SHOW STATUS LIKE 'Qcache%';

-- 查看表的状态
SHOW TABLE STATUS;

-- 查看索引使用情况
SHOW STATUS LIKE 'Handler_read%';

-- 查看数据库大小
SELECT table_schema "Database", 
       SUM(data_length + index_length) / 1024 / 1024 "Size (MB)" 
FROM information_schema.TABLES 
GROUP BY table_schema;

-- 查看每个表的大小
SELECT table_name AS "Table", 
       round(((data_length + index_length) / 1024 / 1024), 2) AS "Size (MB)" 
FROM information_schema.TABLES 
WHERE table_schema = "auyeung-root";

-- 查看锁等待情况
SHOW ENGINE INNODB STATUS;
SHOW STATUS LIKE 'Innodb_row_lock%';

-- 查看事务状态
SHOW ENGINE INNODB STATUS;
SHOW STATUS LIKE 'Innodb_trx%';

-- 查看pt-member库的存储过程
USE `pt-member`;
SHOW PROCEDURE STATUS;

--我想创建一套事务。模仿双色球开奖的过程
-- 1. 生成一组随机数
-- 2. 生成一组中奖号码
-- 3. 比较两组号码，得出中奖结果
-- 4. 将中奖结果插入到数据库中
-- 5. 提交事务
-- 6. 返回中奖结果
-- 7. 如果出现异常，回滚事务
-- 8. 返回异常信息
-- 9. 事务结束
-- 10. 关闭连接
