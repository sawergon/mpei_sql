-- Подготовка данных
INSERT INTO customer (name) VALUES ('Тестовый покупатель');
SET @customer_id = LAST_INSERT_ID();

INSERT INTO category (code, name) VALUES (20, 'Тестовая категория 2');
INSERT INTO product (id, name, price, category_code) VALUES (100, 'Тестовый товар 2', 1500, 20);
-- Создаем новую покупку (корзину)
INSERT INTO purchase (date, customer_id) VALUES (NOW(), @customer_id);
SET @purchase_id = LAST_INSERT_ID();

-- Тест 1: Добавление товара без указания цены
INSERT INTO purchase_items (amount, product_id, purchase_id)
VALUES (2, 100, @purchase_id); -- не указываем inorder_price

SELECT inorder_price FROM purchase_items WHERE purchase_id = @purchase_id;
-- Ожидаемый результат: 1500 (текущая цена товара)

-- Тест 2: Добавление товара с явным указанием цены
INSERT INTO purchase_items (amount, product_id, purchase_id, inorder_price)
VALUES (1, 100, @purchase_id, 1200); -- указываем свою цену

SELECT inorder_price FROM purchase_items
WHERE purchase_id = @purchase_id AND product_id = 100 AND amount = 1;
-- Ожидаемый результат: 1200 (указанная цена)

-- Тест 4: Добавление несуществующего товара
INSERT INTO purchase_items (amount, product_id, purchase_id)
VALUES (1, 999, @purchase_id); -- товара с ID 999 нет
-- Ожидаемый результат: ошибка внешнего ключа