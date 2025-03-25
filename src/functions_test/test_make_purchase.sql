-- Подготовка тестовых данных
INSERT INTO customer (name) VALUES ('Тестовый Клиент');
SET @customer_id = LAST_INSERT_ID();

-- Тест 1: Оформление покупки одного товара
CALL make_purchase(@customer_id, 2, 2);  -- Покупка 2 ноутбуков
SELECT
    p.date,
    p.price AS total_price,
    pi.amount,
    pi.inorder_price AS unit_price
FROM purchase p
         JOIN purchase_items pi ON p.id = pi.purchase_id
WHERE p.customer_id = @customer_id;
-- Ожидаемый результат:
-- total_price = 100000 (2 * 50000)
-- amount = 2
-- unit_price = 50000

-- Тест 2: Попытка купить смартфоны
CALL make_purchase(@customer_id, 1, 10);  -- Пытаемся купить 10 смартфонов
SELECT
    p.date,
    p.price AS total_price,
    pi.amount,
    pi.inorder_price AS unit_price
FROM purchase p
         JOIN purchase_items pi ON p.id = pi.purchase_id
WHERE p.customer_id = @customer_id;
-- Ожидаемый результат:
-- total_price = 40000 (2 * 20000)
-- amount = 10
-- unit_price = 20000