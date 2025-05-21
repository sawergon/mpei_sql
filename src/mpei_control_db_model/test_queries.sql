-- Тестовый скрипт для проверки всех запросов к базе данных

-- Вставка тестовых данных
INSERT INTO category (code, name) VALUES 
    (1, 'Электроника'),
    (2, 'Одежда'),
    (3, 'Книги'),
    (4, 'Спорт'),
    (5, 'Дом и сад');

INSERT INTO customer (name) VALUES 
    ('Иван Иванов'),
    ('Петр Петров'),
    ('Анна Смирнова');

INSERT INTO product (name, price, category_code) VALUES 
    ('Телефон', 50000, 1),
    ('Книга', 1000, 3),
    ('Футболка', 2000, 2),
    ('Гантеля', 3000, 4);

INSERT INTO purchase (date, price, customer_id) VALUES 
    ('2023-01-15 10:00:00', 50000, 1),
    ('2023-02-20 14:30:00', 1000, 1),
    ('2023-03-10 16:45:00', 2000, 2);

INSERT INTO purchase_items (amount, product_id, purchase_id, inorder_price) VALUES 
    (1, 1, 1, 50000),
    (2, 2, 2, 1000),
    (1, 3, 3, 2000);

-- Проверка запроса: из какой категории купил X
SELECT category.name
FROM customer
         JOIN purchase ON customer.id = purchase.customer_id
         JOIN purchase_items ON purchase.id = purchase_items.purchase_id
         JOIN product ON product.id = purchase_items.product_id
         JOIN category ON category.code = product.category_code
WHERE customer.name = 'Иван Иванов'
GROUP BY category.name;

-- Проверка запроса: статистика за прошлый год
SELECT c.name                            as category_name,
       MONTHNAME(p.date)                 as month_name,
       SUM(pi.amount * pi.inorder_price) as total_sales
FROM purchase p
         JOIN purchase_items pi ON p.id = pi.purchase_id
         JOIN product pr ON pi.product_id = pr.id
         JOIN category c ON pr.category_code = c.code
WHERE YEAR(p.date) = YEAR(CURDATE()) - 1
GROUP BY c.name, YEAR(p.date), MONTHNAME(p.date)
ORDER BY MONTHNAME(p.date);

-- Проверка запроса: топ-5 продуктов по популярности
SELECT product.name as name,
       SUM(purchase_items.amount) as amount
FROM product
JOIN purchase_items ON product.id = purchase_items.product_id
GROUP BY name
ORDER BY amount DESC
LIMIT 5;

-- Проверка представления recent_high_value_purchases
SELECT * FROM recent_high_value_purchases;

-- Проверка размеров партиций
SELECT 
    table_schema, 
    table_name, 
    format_bytes(data_length + index_length) as size
FROM information_schema.tables
WHERE table_schema = 'mpei_control_db_model'
AND table_name LIKE 'product_partition_%'
   OR table_name LIKE 'purchase_%'
   OR table_name LIKE 'purchase_items_partition_%'
ORDER BY table_name;

-- Проверка использования индексов
EXPLAIN
SELECT * FROM product WHERE category_code = 1;

EXPLAIN
SELECT * FROM purchase WHERE date >= '2023-01-01';

EXPLAIN
SELECT * FROM purchase_items WHERE product_id = 1;