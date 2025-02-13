-- 检查事件调度器状态
SHOW VARIABLES LIKE 'event_scheduler';

-- 检查所有事件状态
SHOW EVENTS;

-- 检查系统运行状态
CALL sp_check_lottery_status();

-- 首先确保Event Scheduler是开启的
SET GLOBAL event_scheduler = ON;

-- 如果已存在相同名称的事件，先删除
DROP EVENT IF EXISTS evt_minute_lottery;

-- 创建每分钟执行一次的事件
DELIMITER //

CREATE EVENT evt_minute_lottery
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
DO
BEGIN
    -- 声明变量用于记录执行状态
    DECLARE exec_status VARCHAR(100);
    -- 声明错误处理程序
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 发生错误时记录错误信息
        INSERT INTO lottery_execution_logs (status, message)
        VALUES ('ERROR', CONCAT('Error occurred at: ', NOW()));
        -- 回滚事务
        ROLLBACK;
    END;
    
    -- 记录开始执行
    SET exec_status = CONCAT('Lottery draw started at: ', NOW());
    
    -- 将执行状态插入日志表（首先创建日志表）
    CREATE TABLE IF NOT EXISTS lottery_execution_logs (
        id BIGINT PRIMARY KEY AUTO_INCREMENT,
        execution_time DATETIME DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR(100),
        message TEXT
    );
    
    -- 开始事务
    START TRANSACTION;
    
    -- 插入开始执行日志
    INSERT INTO lottery_execution_logs (status, message)
    VALUES ('START', exec_status);
    
    -- 调用开奖存储过程
    CALL sp_lottery_draw();
    
    -- 记录执行完成
    INSERT INTO lottery_execution_logs (status, message)
    VALUES ('COMPLETE', CONCAT('Lottery draw completed at: ', NOW()));
    
    -- 提交事务
    COMMIT;
END //

DELIMITER ;

-- 创建查看最近开奖结果的视图
CREATE OR REPLACE VIEW v_recent_lottery_results AS
SELECT 
    draw_date,
    user_numbers,
    winning_numbers,
    match_result,
    prize_amount
FROM lottery_results
ORDER BY draw_date DESC
LIMIT 10;

-- 创建用于检查事件状态的存储过程
DELIMITER //

CREATE PROCEDURE sp_check_lottery_status()
BEGIN
    -- 检查Event Scheduler状态
    SELECT @@event_scheduler as 'Event Scheduler Status';
    
    -- 检查彩票事件状态
    SELECT 
        EVENT_SCHEMA,
        EVENT_NAME,
        STATUS,
        LAST_EXECUTED,
        STARTS,
        ENDS,
        INTERVAL_VALUE,
        INTERVAL_FIELD
    FROM information_schema.events
    WHERE EVENT_NAME = 'evt_minute_lottery';
    
    -- 显示最近的执行日志
    SELECT *
    FROM lottery_execution_logs
    ORDER BY execution_time DESC
    LIMIT 5;
    
    -- 显示最近的开奖结果
    SELECT *
    FROM v_recent_lottery_results
    LIMIT 5;
END //

DELIMITER ;

-- 添加一个用于清理旧日志的事件（每天执行一次）
DELIMITER //

CREATE EVENT evt_clean_old_logs
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
BEGIN
    -- 删除30天前的日志
    DELETE FROM lottery_execution_logs 
    WHERE execution_time < DATE_SUB(NOW(), INTERVAL 30 DAY);
END //

DELIMITER ;



SHOW VARIABLES LIKE 'event_scheduler';
SHOW EVENTS;
CALL sp_check_lottery_status();
