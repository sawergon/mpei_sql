-- ========================================================================
-- Скрипт для MySQL: Генерация данных, измерения и сводный отчёт
-- ========================================================================
-- Определены четыре процедуры генерации данных и сводная процедура,
-- которая вызывает их, измеряет время генерации и сравнивает время запросов
-- с условием (фильтром) и сортировкой для таблиц с и без индексов.

DELIMITER $$

-- ------------------------------------------------------------------------
-- 1. Поэлементная вставка без индексов
-- ------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS generate_data_slow$$
CREATE PROCEDURE generate_data_slow(IN p_num_rows INT)
BEGIN
    DECLARE v_i INT DEFAULT 1;
    DECLARE v_rand INT;
    DECLARE v_str VARCHAR(100);
CREATE TABLE IF NOT EXISTS large_table_slow (
                                                id INT AUTO_INCREMENT PRIMARY KEY,
                                                numeric_value INT,
                                                string_value VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
TRUNCATE TABLE large_table_slow;
WHILE v_i <= p_num_rows DO
        SET v_rand = FLOOR(RAND() * 1000000);
        SET v_str = CONCAT('String_', MD5(RAND()));
INSERT INTO large_table_slow (numeric_value, string_value) VALUES (v_rand, v_str);
SET v_i = v_i + 1;
END WHILE;
END$$

-- ------------------------------------------------------------------------
-- 2. Поэлементная вставка с индексами
-- ------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS generate_data_slow_with_index$$
CREATE PROCEDURE generate_data_slow_with_index(IN p_num_rows INT)
BEGIN
    DECLARE v_i INT DEFAULT 1;
    DECLARE v_rand INT;
    DECLARE v_str VARCHAR(100);
CREATE TABLE IF NOT EXISTS large_table_slow_indexed (
                                                        id INT AUTO_INCREMENT PRIMARY KEY,
                                                        numeric_value INT,
                                                        string_value VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_numeric (numeric_value),
    INDEX idx_string (string_value),
    INDEX idx_comp (numeric_value, string_value)
    );
TRUNCATE TABLE large_table_slow_indexed;
WHILE v_i <= p_num_rows DO
        SET v_rand = FLOOR(RAND() * 1000000);
        SET v_str = CONCAT('String_', MD5(RAND()));
INSERT INTO large_table_slow_indexed (numeric_value, string_value) VALUES (v_rand, v_str);
SET v_i = v_i + 1;
END WHILE;
END$$

-- ------------------------------------------------------------------------
-- 3. Быстрая вставка пакетами без индексов
-- ------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS generate_data_fast$$
CREATE PROCEDURE generate_data_fast(IN p_num_rows INT)
BEGIN
    DECLARE v_chunk INT DEFAULT 100000;
    DECLARE v_full INT DEFAULT FLOOR(p_num_rows/v_chunk);
    DECLARE v_rem INT DEFAULT p_num_rows % v_chunk;
    DECLARE i INT;
CREATE TABLE IF NOT EXISTS large_table_fast (
                                                id INT AUTO_INCREMENT PRIMARY KEY,
                                                numeric_value INT,
                                                string_value VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
TRUNCATE TABLE large_table_fast;
SET i = 1;
    WHILE i <= v_full DO
        INSERT INTO large_table_fast (numeric_value, string_value)
SELECT FLOOR(RAND()*1000000), CONCAT('String_', MD5(RAND())) FROM (SELECT 1 FROM dual LIMIT v_chunk) t;
SET i = i + 1;
END WHILE;
    IF v_rem > 0 THEN
        INSERT INTO large_table_fast (numeric_value, string_value)
SELECT FLOOR(RAND()*1000000), CONCAT('String_', MD5(RAND())) FROM (SELECT 1 FROM dual LIMIT v_rem) t;
END IF;
END$$

-- ------------------------------------------------------------------------
-- 4. Быстрая вставка пакетами с индексами
-- ------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS generate_data_fast_with_index$$
CREATE PROCEDURE generate_data_fast_with_index(IN p_num_rows INT)
BEGIN
    DECLARE v_batch INT DEFAULT 20000;
    DECLARE v_total INT;
    DECLARE b INT DEFAULT 1;
    DECLARE sz INT;
CREATE TABLE IF NOT EXISTS large_table_fast_indexed (
                                                        id INT AUTO_INCREMENT PRIMARY KEY,
                                                        numeric_value INT,
                                                        string_value VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
ALTER TABLE large_table_fast_indexed
    ADD INDEX idx_num (numeric_value),
        ADD INDEX idx_str (string_value),
        ADD INDEX idx_comp (numeric_value, string_value);
TRUNCATE TABLE large_table_fast_indexed;
SET v_total = CEIL(p_num_rows/v_batch);
    WHILE b <= v_total DO
        SET sz = p_num_rows - (b-1)*v_batch;
        IF sz > v_batch THEN SET sz = v_batch; END IF;
INSERT INTO large_table_fast_indexed (numeric_value, string_value)
SELECT FLOOR(RAND()*1000000), CONCAT('String_', MD5(RAND())) FROM (SELECT 1 FROM dual LIMIT sz) t;
SET b = b + 1;
END WHILE;
END$$

-- ------------------------------------------------------------------------
-- Таблица для сбора отчёта запросов
-- ------------------------------------------------------------------------
DROP TABLE IF EXISTS query_report;
CREATE TABLE query_report (
                              table_name VARCHAR(50),
                              rows_tested INT,
                              filter_no_idx_sec DECIMAL(15,6),
                              filter_with_idx_sec DECIMAL(15,6),
                              sort_no_idx_sec   DECIMAL(15,6),
                              sort_with_idx_sec DECIMAL(15,6)
);

-- ------------------------------------------------------------------------
-- Сводная процедура: генерация и сравнение запросов
-- ------------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS run_full_benchmark$$
CREATE PROCEDURE run_full_benchmark(IN p_rows INT)
BEGIN
    DECLARE t0, t1 DATETIME;
    DECLARE sec INT;
    DECLARE cnt INT;
TRUNCATE TABLE query_report;

-- Генерация для всех таблиц
CALL generate_data_slow(p_rows);
CALL generate_data_slow_with_index(p_rows);
CALL generate_data_fast(p_rows);
CALL generate_data_fast_with_index(p_rows);

-- Список таблиц для теста
SET @tbl1 = 'large_table_slow';
    SET @tbl2 = 'large_table_slow_indexed';
    SET @tbl3 = 'large_table_fast';
    SET @tbl4 = 'large_table_fast_indexed';

    -- Тестируем для каждой таблицы
    DECLARE cur CURSOR FOR SELECT tbl FROM (
                                                                           SELECT @tbl1 AS tbl UNION ALL
                                                                           SELECT @tbl2 UNION ALL
                                                                           SELECT @tbl3 UNION ALL
                                                                           SELECT @tbl4
                                                                       ) AS list;
DECLARE done INT DEFAULT 0;
    DECLARE cur_tbl VARCHAR(50);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

OPEN cur;
read_loop: LOOP
        FETCH cur INTO cur_tbl;
        IF done THEN LEAVE read_loop; END IF;
        -- Фильтр
        SET t0 = NOW();
        SET @s = CONCAT('SELECT COUNT(*) INTO @cnt FROM ', cur_tbl, ' WHERE numeric_value BETWEEN 100000 AND 200000');
PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET t1 = NOW();
        SET sec = TIMESTAMPDIFF(SECOND, t0, t1);
        SET @filter_no_idx = IF(cur_tbl LIKE '%indexed%', NULL, sec);
        SET @filter_with_idx = IF(cur_tbl LIKE '%indexed%', sec, NULL);
        -- Сортировка
        SET t0 = NOW();
        SET @s = CONCAT('SELECT * FROM ', cur_tbl, ' ORDER BY numeric_value LIMIT 1000');
PREPARE stmt FROM @s; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET t1 = NOW();
        SET sec = TIMESTAMPDIFF(SECOND, t0, t1);
        SET @sort_no_idx = IF(cur_tbl LIKE '%indexed%', NULL, sec);
        SET @sort_with_idx = IF(cur_tbl LIKE '%indexed%', sec, NULL);
        -- Вставляем в отчёт
INSERT INTO query_report VALUES(
                                   cur_tbl, p_rows,
                                   COALESCE(@filter_no_idx, 0),
                                   COALESCE(@filter_with_idx, 0),
                                   COALESCE(@sort_no_idx, 0),
                                   COALESCE(@sort_with_idx, 0)
                               );
END LOOP;
CLOSE cur;

-- Вывод отчёта
SELECT * FROM query_report;
END$$

DELIMITER ;

-- Пример: CALL run_full_benchmark(50000);