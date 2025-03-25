DELIMITER //
CREATE TRIGGER prevent_category_deletion
    BEFORE DELETE ON category
    FOR EACH ROW
BEGIN
    DECLARE product_count INT;

    -- Проверяем, есть ли товары в этой категории
    SELECT COUNT(*) INTO product_count
    FROM product
    WHERE category_code = OLD.code;

    -- Если товары есть, отменяем удаление
    IF product_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Нельзя удалить категорию с товарами. Сначала удалите или переместите товары.';
    END IF;
END //
DELIMITER ;