DELIMITER //
CREATE PROCEDURE calculate_category_totals_for_customer(IN customer_id INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cat_name VARCHAR(255);
    DECLARE total DOUBLE;

    -- Объявляем курсор для выборки категорий и сумм
    DECLARE cur CURSOR FOR
        SELECT
            cat.name,
            SUM(pi.amount * pi.inorder_price) AS category_total
        FROM
            purchase_items pi
                JOIN
            product prod ON pi.product_id = prod.id
                JOIN
            category cat ON prod.category_code = cat.code
                JOIN
            purchase p ON pi.purchase_id = p.id
        WHERE
            p.customer_id = customer_id
        GROUP BY
            cat.name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Создаем временную таблицу для результатов
    DROP TEMPORARY TABLE IF EXISTS temp_results;
    CREATE TEMPORARY TABLE temp_results (
                                            category_name VARCHAR(255),
                                            total_amount DOUBLE
    );

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO cat_name, total;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Вставляем данные во временную таблицу
        INSERT INTO temp_results VALUES (cat_name, total);
    END LOOP;

    CLOSE cur;

    -- Возвращаем результаты
    SELECT * FROM temp_results ORDER BY total_amount DESC;

    DROP TEMPORARY TABLE IF EXISTS temp_results;
END //
DELIMITER ;