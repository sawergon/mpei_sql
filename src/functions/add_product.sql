DELIMITER //
CREATE PROCEDURE add_product(
    IN p_name VARCHAR(255),
    IN p_price DECIMAL(10,2),
    IN p_category_code INT,
    OUT p_product_id INT
)
BEGIN
INSERT INTO product(name, price, category_code)
VALUES (p_name, p_price, p_category_code);
SET p_product_id = LAST_INSERT_ID();
END //
DELIMITER ;