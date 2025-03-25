DELIMITER //
CREATE TRIGGER set_product_price_on_cart_insert
    BEFORE INSERT ON purchase_items
    FOR EACH ROW
BEGIN
    DECLARE current_price DECIMAL(10,2);

    SELECT price INTO current_price
    FROM product
    WHERE id = NEW.product_id;

    IF NEW.inorder_price IS NULL OR NEW.inorder_price = 0 THEN
        SET NEW.inorder_price = current_price;
    END IF;
END//
DELIMITER ;