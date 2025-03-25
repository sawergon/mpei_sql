DELIMITER //
CREATE PROCEDURE make_purchase(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_amount INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_purchase_id INT;

    -- Получаем текущую цену товара
SELECT price INTO v_price FROM product WHERE id = p_product_id;

-- Создаем запись о покупке
INSERT INTO purchase(date, customer_id) VALUES (NOW(), p_customer_id);
SET v_purchase_id = LAST_INSERT_ID();

    -- Добавляем товары в покупку
INSERT INTO purchase_items(amount, product_id, purchase_id, inorder_price)
VALUES (p_amount, p_product_id, v_purchase_id, v_price);

-- Обновляем общую стоимость покупки
UPDATE purchase SET price = (SELECT SUM(amount * inorder_price)
                             FROM purchase_items WHERE purchase_id = v_purchase_id)
WHERE id = v_purchase_id;
END //
DELIMITER ;