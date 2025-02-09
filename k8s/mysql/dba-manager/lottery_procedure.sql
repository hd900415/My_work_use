-- 创建双色球开奖结果表
CREATE TABLE IF NOT EXISTS lottery_results (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    draw_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    user_numbers VARCHAR(50),  -- 用户选择的号码
    winning_numbers VARCHAR(50),  -- 中奖号码
    match_result VARCHAR(20),  -- 中奖等级
    prize_amount DECIMAL(12,2),  -- 奖金金额
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 创建双色球开奖存储过程
DELIMITER //

CREATE PROCEDURE sp_lottery_draw()
BEGIN
    -- 声明变量
    DECLARE user_red1, user_red2, user_red3, user_red4, user_red5, user_red6, user_blue INT;
    DECLARE win_red1, win_red2, win_red3, win_red4, win_red5, win_red6, win_blue INT;
    DECLARE red_matches INT DEFAULT 0;
    DECLARE blue_match BOOLEAN DEFAULT FALSE;
    DECLARE result_level VARCHAR(20);
    DECLARE prize DECIMAL(12,2) DEFAULT 0;
    DECLARE user_numbers, winning_numbers VARCHAR(50);
    
    -- 声明异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- 发生异常时回滚事务
        ROLLBACK;
        SELECT 'Error occurred during lottery draw process' AS error_message;
    END;

    -- 开始事务
    START TRANSACTION;
    
    -- 1. 生成用户随机号码（6个红球1-33，1个蓝球1-16）
    SET user_red1 = FLOOR(1 + RAND() * 33);
    SET user_red2 = FLOOR(1 + RAND() * 33);
    SET user_red3 = FLOOR(1 + RAND() * 33);
    SET user_red4 = FLOOR(1 + RAND() * 33);
    SET user_red5 = FLOOR(1 + RAND() * 33);
    SET user_red6 = FLOOR(1 + RAND() * 33);
    SET user_blue = FLOOR(1 + RAND() * 16);
    
    -- 2. 生成中奖号码
    SET win_red1 = FLOOR(1 + RAND() * 33);
    SET win_red2 = FLOOR(1 + RAND() * 33);
    SET win_red3 = FLOOR(1 + RAND() * 33);
    SET win_red4 = FLOOR(1 + RAND() * 33);
    SET win_red5 = FLOOR(1 + RAND() * 33);
    SET win_red6 = FLOOR(1 + RAND() * 33);
    SET win_blue = FLOOR(1 + RAND() * 16);
    
    -- 格式化号码字符串
    SET user_numbers = CONCAT(user_red1, ',', user_red2, ',', user_red3, ',', 
                            user_red4, ',', user_red5, ',', user_red6, '+', user_blue);
    SET winning_numbers = CONCAT(win_red1, ',', win_red2, ',', win_red3, ',', 
                               win_red4, ',', win_red5, ',', win_red6, '+', win_blue);
    
    -- 3. 比较号码，计算匹配数
    SET red_matches = 
        (user_red1 = win_red1 OR user_red1 = win_red2 OR user_red1 = win_red3 OR 
         user_red1 = win_red4 OR user_red1 = win_red5 OR user_red1 = win_red6) +
        (user_red2 = win_red1 OR user_red2 = win_red2 OR user_red2 = win_red3 OR 
         user_red2 = win_red4 OR user_red2 = win_red5 OR user_red2 = win_red6) +
        (user_red3 = win_red1 OR user_red3 = win_red2 OR user_red3 = win_red3 OR 
         user_red3 = win_red4 OR user_red3 = win_red5 OR user_red3 = win_red6) +
        (user_red4 = win_red1 OR user_red4 = win_red2 OR user_red4 = win_red3 OR 
         user_red4 = win_red4 OR user_red4 = win_red5 OR user_red4 = win_red6) +
        (user_red5 = win_red1 OR user_red5 = win_red2 OR user_red5 = win_red3 OR 
         user_red5 = win_red4 OR user_red5 = win_red5 OR user_red5 = win_red6) +
        (user_red6 = win_red1 OR user_red6 = win_red2 OR user_red6 = win_red3 OR 
         user_red6 = win_red4 OR user_red6 = win_red5 OR user_red6 = win_red6);
    
    SET blue_match = (user_blue = win_blue);
    
    -- 判断中奖等级
    IF red_matches = 6 AND blue_match THEN
        SET result_level = '一等奖';
        SET prize = 5000000.00;
    ELSEIF red_matches = 6 AND NOT blue_match THEN
        SET result_level = '二等奖';
        SET prize = 200000.00;
    ELSEIF red_matches = 5 AND blue_match THEN
        SET result_level = '三等奖';
        SET prize = 3000.00;
    ELSEIF (red_matches = 5 AND NOT blue_match) OR (red_matches = 4 AND blue_match) THEN
        SET result_level = '四等奖';
        SET prize = 200.00;
    ELSEIF (red_matches = 4 AND NOT blue_match) OR (red_matches = 3 AND blue_match) THEN
        SET result_level = '五等奖';
        SET prize = 10.00;
    ELSEIF (red_matches = 2 AND blue_match) OR (red_matches = 1 AND blue_match) OR (red_matches = 0 AND blue_match) THEN
        SET result_level = '六等奖';
        SET prize = 5.00;
    ELSE
        SET result_level = '未中奖';
        SET prize = 0.00;
    END IF;
    
    -- 4. 将结果插入数据库
    INSERT INTO lottery_results (user_numbers, winning_numbers, match_result, prize_amount)
    VALUES (user_numbers, winning_numbers, result_level, prize);
    
    -- 5. 提交事务
    COMMIT;
    
    -- 6. 返回中奖结果
    SELECT 
        '开奖成功' as status,
        user_numbers as '您的号码',
        winning_numbers as '中奖号码',
        result_level as '中奖结果',
        prize as '奖金金额';
        
END //

DELIMITER ;
CALL sp_lottery_draw();
CALL sp_lottery_draw();



