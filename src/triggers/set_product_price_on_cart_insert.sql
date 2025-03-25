DELIMITER //
CREATE TRIGGER set_product_price_on_cart_insert
    BEFORE INSERT ON purchase_items
    FOR EACH ROW
BEGIN
    DECLARE current_price DECIMAL(10,2);

    -- Получаем текущую цену товара
    SELECT price INTO current_price
    FROM product
    WHERE id = NEW.product_id;

    -- Если цена не указана, устанавливаем текущую цену
    IF NEW.inorder_price IS NULL OR NEW.inorder_price = 0 THEN
        SET NEW.inorder_price = current_price;
    END IF;
END//
DELIMITER ;