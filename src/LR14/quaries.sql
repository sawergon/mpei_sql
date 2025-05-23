-- Список клиентов и товаров
SELECT name AS entity_name, 'customer' AS entity_type
FROM customer
UNION
SELECT name AS entity_name, 'product' AS entity_type
FROM product;


ALTER TABLE category ADD parent_code INT;

INSERT INTO category (code, name, parent_code) VALUES
    (11, 'Бытовая электроника', 1),
    (12, 'Компьютерная периферия', 1);

-- Выбор гатегории и ее подкатегорий:
WITH RECURSIVE category_tree AS (
    SELECT code, name, parent_code, 0 AS level
    FROM category
    WHERE code = 1  -- Корневая категория

    UNION ALL

    SELECT c.code, c.name, c.parent_code, ct.level + 1
    FROM category c
             JOIN category_tree ct ON c.parent_code = ct.code
)
SELECT * FROM category_tree;


-- Ранжирование всех покупок по стоимости для каждого клиента.
SELECT
    c.name AS customer_name,
    p.date AS purchase_date,
    p.price AS purchase_total,
    RANK() OVER (PARTITION BY c.id ORDER BY p.price DESC) AS price_rank,
    SUM(p.price) OVER (PARTITION BY c.id ORDER BY p.date) AS running_total
FROM purchase p
         JOIN customer c ON p.customer_id = c.id;

