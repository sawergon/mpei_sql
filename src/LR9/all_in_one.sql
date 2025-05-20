-- ========================================================================
-- Генерация больших объёмов данных
-- ========================================================================
-- В этом скрипте определены четыре хранимые процедуры для генерации данных:
-- 1. generate_data_slow: поэлементная вставка без индексов
-- 2. generate_data_slow_with_index: поэлементная вставка с индексами
-- 3. generate_data_fast: быстрая вставка пакетами без индексов
-- 4. generate_data_fast_with_index: быстрая вставка пакетами с индексами

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

    CREATE TABLE IF NOT EXISTS large_table_slow
    (
        id            INT AUTO_INCREMENT PRIMARY KEY,
        numeric_value INT,
        string_value  VARCHAR(100),
        created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    TRUNCATE TABLE large_table_slow;

    WHILE v_i <= p_num_rows
        DO
            SET v_rand = FLOOR(RAND() * 1000000);
            SET v_str = CONCAT('String_', MD5(RAND()));
            INSERT INTO large_table_slow (numeric_value, string_value)
            VALUES (v_rand, v_str);
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

    CREATE TABLE IF NOT EXISTS large_table_slow_indexed
    (
        id            INT AUTO_INCREMENT PRIMARY KEY,
        numeric_value INT,
        string_value  VARCHAR(100),
        created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_numeric (numeric_value),
        INDEX idx_string (string_value),
        INDEX idx_comp (numeric_value, string_value)
    );
    TRUNCATE TABLE large_table_slow_indexed;

    WHILE v_i <= p_num_rows
        DO
            SET v_rand = FLOOR(RAND() * 1000000);
            SET v_str = CONCAT('String_', MD5(RAND()));
            INSERT INTO large_table_slow_indexed (numeric_value, string_value)
            VALUES (v_rand, v_str);
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
    DECLARE v_full INT DEFAULT FLOOR(p_num_rows / v_chunk);
    DECLARE v_rem INT DEFAULT p_num_rows % v_chunk;
    DECLARE i INT;

    CREATE TABLE IF NOT EXISTS large_table_fast
    (
        id            INT AUTO_INCREMENT PRIMARY KEY,
        numeric_value INT,
        string_value  VARCHAR(100),
        created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    TRUNCATE TABLE large_table_fast;

    SET i = 1;
    WHILE i <= v_full
        DO
            INSERT INTO large_table_fast (numeric_value, string_value)
            SELECT FLOOR(RAND() * 1000000), CONCAT('String_', MD5(RAND()))
            FROM (SELECT 1 FROM dual LIMIT v_chunk) t;
            SET i = i + 1;
        END WHILE;
    IF v_rem > 0 THEN
        INSERT INTO large_table_fast (numeric_value, string_value)
        SELECT FLOOR(RAND() * 1000000), CONCAT('String_', MD5(RAND()))
        FROM (SELECT 1 FROM dual LIMIT v_rem) t;
    END IF;
END$$

-- ------------------------------------------------------------------------
-- 4. Быстрая вставка пакетами с индексами
-- ------------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS generate_data_fast_with_index$$
CREATE PROCEDURE generate_data_fast_with_index(IN p_num_rows INT)
BEGIN
    DECLARE v_batch INT DEFAULT 20000;
    DECLARE v_total INT;
    DECLARE b INT DEFAULT 1;
    DECLARE sz INT;

    CREATE TABLE IF NOT EXISTS large_table_fast_indexed
    (
        id            INT AUTO_INCREMENT PRIMARY KEY,
        numeric_value INT,
        string_value  VARCHAR(100),
        created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    IF NOT EXISTS (SELECT 1 FROM information_schema.statistics
                   WHERE table_schema = DATABASE()
                   AND table_name = 'large_table_fast_indexed'
                   AND index_name = 'idx_num') THEN
        ALTER TABLE large_table_fast_indexed ADD INDEX idx_num (numeric_value);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.statistics
                   WHERE table_schema = DATABASE()
                   AND table_name = 'large_table_fast_indexed'
                   AND index_name = 'idx_str') THEN
        ALTER TABLE large_table_fast_indexed ADD INDEX idx_str (string_value);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.statistics
                   WHERE table_schema = DATABASE()
                   AND table_name = 'large_table_fast_indexed'
                   AND index_name = 'idx_comp') THEN
        ALTER TABLE large_table_fast_indexed ADD INDEX idx_comp (numeric_value, string_value);
    END IF;
    TRUNCATE TABLE large_table_fast_indexed;

    SET v_total = CEIL(p_num_rows / v_batch);
    WHILE b <= v_total
        DO
            SET sz = p_num_rows - (b - 1) * v_batch;
            IF sz > v_batch THEN SET sz = v_batch; END IF;
            INSERT INTO large_table_fast_indexed (numeric_value, string_value)
            SELECT FLOOR(RAND() * 1000000), CONCAT('String_', MD5(RAND()))
            FROM (SELECT 1 FROM dual LIMIT sz) t;
            SET b = b + 1;
        END WHILE;
END$$

-- ------------------------------------------------------------------------
-- Таблица для сбора отчёта
-- ------------------------------------------------------------------------
DROP TABLE IF EXISTS generation_report;
CREATE TABLE generation_report
(
    method       VARCHAR(50),
    row_count    INT,
    duration_insert_sec DECIMAL(15, 6),
    duration_select_sec_avg DECIMAL(15, 6),
    duration_sort_sec DECIMAL(15, 6)
);

-- ------------------------------------------------------------------------
-- 5. Сводная процедура: вызывает все четыре метода и сохраняет результаты
-- ------------------------------------------------------------------------
DELIMITER $$

-- Вспомогательная процедура для запуска генераторов
DROP PROCEDURE IF EXISTS run_generator$$
CREATE PROCEDURE run_generator(
    IN method_part VARCHAR(50),
    IN with_index BOOLEAN,
    IN multiplier INT,
    IN base_rows INT
)
BEGIN
    DECLARE t0 DATETIME;
    DECLARE t1 DATETIME;
    DECLARE t2 DATETIME;
    DECLARE t3 DATETIME;
    DECLARE t4 DATETIME;
    DECLARE t5 DATETIME;
    DECLARE proc_name VARCHAR(100);
    DECLARE rows_to_generate INT;
    DECLARE method_name VARCHAR(50);
    DECLARE table_name VARCHAR(50);

    SET rows_to_generate = base_rows * multiplier;
    SET method_name = CONCAT(
            method_part,
            CASE when with_index THEN '_with_idx' ELSE '_no_idx' END
                      );

    SET table_name = CONCAT('large_table_', method_part, IF(with_index, '_indexed', ''));

    -- Формируем имя вызываемой процедуры
    SET proc_name = CONCAT('generate_data_', method_part);
    IF with_index THEN
        SET proc_name = CONCAT(proc_name, '_with_index');
    END IF;

    -- Вызываем целевую процедуру
    SET t0 = NOW();
    SET @sql = CONCAT('CALL ', proc_name, '(?);');
    PREPARE stmt FROM @sql;
    SET @rows_param = rows_to_generate;
    EXECUTE stmt USING @rows_param;
    DEALLOCATE PREPARE stmt;
    SET t1 = NOW();

    -- Бенчмарк: доступ к таблице
    SET @s = CONCAT('INSERT INTO temp_bench (dummy) SELECT 1 FROM ', table_name, ' WHERE numeric_value > ?');
    PREPARE stmt FROM @s;

    SET @sum = 0;
    SET @cnt = 0;
    WHILE @cnt < 10000 DO
        SET @p = FLOOR(RAND() * 1000000);
        SET t2 = NOW();
        EXECUTE stmt USING @p;
        SET t3 = NOW();
        SET @sum = @sum + TIMESTAMPDIFF(SECOND, t2, t3);
        SET @cnt = @cnt + 1;
    END WHILE;
    SET @avg = @sum / @cnt;

    DEALLOCATE PREPARE stmt;

    -- отключим вывод
    SET @old_sql_log_bin = @@sql_log_bin;
    SET sql_log_bin = 0;

    -- Бенчмарк: сортировка
    SET @s = CONCAT('INSERT INTO temp_bench (dummy) SELECT 1 FROM ', table_name, ' ORDER BY numeric_value');
    PREPARE stmt FROM @s;
    SET t4 = NOW();
    EXECUTE stmt;
    SET t5 = NOW();

    -- включим вывод
    SET sql_log_bin = @old_sql_log_bin;
    -- Сохраняем результаты
    INSERT INTO generation_report (method, row_count, duration_insert_sec, duration_select_sec_avg, duration_sort_sec)
    VALUES (
               method_name,
               rows_to_generate,
               TIMESTAMPDIFF(SECOND, t0, t1),
 @avg,
            TIMESTAMPDIFF(SECOND , t4, t5)
           );
END$$

-- Основная процедура
DROP PROCEDURE IF EXISTS run_all_generators$$
CREATE PROCEDURE run_all_generators(IN p_rows INT)
BEGIN
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE cur_mult INT;

    -- Для хранения множителей
    DECLARE cur CURSOR FOR
        SELECT mult FROM (SELECT 1 AS mult UNION SELECT 4 UNION SELECT 10
                          UNION SELECT 100 UNION SELECT 10000) AS multipliers;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    TRUNCATE TABLE generation_report;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_bench (
                                                        dummy INT
    );

    -- Запуск slow методов
    CALL run_generator('slow', FALSE, 1, p_rows);
    CALL run_generator('slow', TRUE, 1, p_rows);
    -- Запуск fast методов с разными множителями
    OPEN cur;
    loop1: LOOP
        FETCH cur INTO cur_mult;
        IF done THEN LEAVE loop1; END IF;

        CALL run_generator('fast', FALSE, cur_mult, p_rows);
        CALL run_generator('fast', TRUE, cur_mult, p_rows);
    END LOOP;
    CLOSE cur;

    -- Результаты
    SELECT * FROM generation_report;
END$$

DELIMITER ;

CALL run_all_generators(10000);
SELECT * FROM generation_report order by 1;