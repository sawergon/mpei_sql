DELIMITER //
CREATE FUNCTION get_customer_purchase_total(customer_id INT)
    RETURNS DECIMAL(10,2)
    READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);

SELECT SUM(p.price) INTO total
FROM purchase p
WHERE p.customer_id = customer_id;

RETURN IFNULL(total, 0);
END //
DELIMITER ;