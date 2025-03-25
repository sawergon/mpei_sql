DELIMITER //
CREATE FUNCTION calculate_category_total(category_id INT)
    RETURNS DECIMAL(10,2)
    DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
SELECT SUM(price) INTO total FROM product WHERE category_code = category_id;
RETURN IFNULL(total, 0);
END //
DELIMITER ;