-- Создание новой схемы для партицированных таблиц
CREATE SCHEMA IF NOT EXISTS new_schema;

-- Таблица категорий (остается без партицирования)
CREATE TABLE IF NOT EXISTS new_schema.category
(
    code INT          NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NULL,
    CONSTRAINT category_pk PRIMARY KEY (code)
);

-- Таблица клиентов (остается без партицирования)
CREATE TABLE IF NOT EXISTS new_schema.customer
(
    id   INT AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    CONSTRAINT customer_pk PRIMARY KEY (id)
);

-- Таблица продуктов с партицированием по категории для оптимизации запросов
CREATE TABLE IF NOT EXISTS new_schema.product
(
    id            INT AUTO_INCREMENT,
    name          VARCHAR(255) NULL,
    price         DOUBLE DEFAULT 0.0,
    category_code INT          NOT NULL,
    CONSTRAINT product_pk PRIMARY KEY (id, category_code)
) PARTITION BY LIST (category_code) (
    PARTITION p1 VALUES IN (1),
    PARTITION p2 VALUES IN (2),
    PARTITION p3 VALUES IN (3),
    PARTITION p4 VALUES IN (4),
    PARTITION p_other VALUES IN (0, 5, 6, 7, 8, 9)
    );

-- Таблица для поддержки связи между продуктами и категориями
CREATE TABLE IF NOT EXISTS new_schema.product_category_link
(
    product_id    INT NOT NULL,
    category_code INT NOT NULL,
    CONSTRAINT product_category_link_pk PRIMARY KEY (product_id, category_code)
);

-- Таблица покупок с партицированием по дате для оптимизации временных запросов
CREATE TABLE IF NOT EXISTS new_schema.purchase
(
    id          INT AUTO_INCREMENT,
    date        DATETIME                                              NOT NULL,
    date_ts     INT                                                   NOT NULL,
    price       DOUBLE DEFAULT 0.0,
    customer_id INT                                                   NULL,
    PRIMARY KEY (id, date_ts)
)
    PARTITION BY RANGE (date_ts) (
        PARTITION p2022 VALUES LESS THAN (1735689600), -- 2023-01-01 00:00:00
        PARTITION p2023 VALUES LESS THAN (1772227200), -- 2024-01-01 00:00:00
        PARTITION pmax VALUES LESS THAN MAXVALUE
        );

-- Триггер для автоматического заполнения date_ts
DELIMITER //
CREATE TRIGGER new_schema.before_purchase_insert
    BEFORE INSERT ON new_schema.purchase
    FOR EACH ROW
BEGIN
    SET NEW.date_ts = UNIX_TIMESTAMP(NEW.date);
END//
DELIMITER ;

-- Таблица для поддержки связи между покупками и клиентами
CREATE TABLE IF NOT EXISTS new_schema.purchase_customer_link
(
    purchase_id INT NOT NULL,
    customer_id INT NOT NULL,
    CONSTRAINT purchase_customer_link_pk PRIMARY KEY (purchase_id, customer_id)
);

-- Таблица покупок по продуктам с партицированием по покупке
CREATE TABLE IF NOT EXISTS new_schema.purchase_items
(
    amount        INT    DEFAULT 0,
    product_id    INT NULL,
    purchase_id   INT NOT NULL,
    inorder_price DOUBLE DEFAULT 0.0 COMMENT 'product price in time where it was bought',
    CONSTRAINT purchase_items_pk PRIMARY KEY (purchase_id, amount)
) PARTITION BY RANGE (purchase_id) (
    PARTITION p1 VALUES LESS THAN (5),
    PARTITION p2 VALUES LESS THAN (10),
    PARTITION p3 VALUES LESS THAN MAXVALUE
    );

-- Таблица для поддержки связи между покупками и продуктами
CREATE TABLE IF NOT EXISTS new_schema.purchase_items_link
(
    purchase_id INT NOT NULL,
    product_id  INT NOT NULL,
    CONSTRAINT purchase_items_link_pk PRIMARY KEY (purchase_id, product_id)
);

-- Создание индексов для оптимизации запросов
CREATE INDEX idx_product_category ON new_schema.product (category_code);
CREATE INDEX idx_purchase_date ON new_schema.purchase (date);
CREATE INDEX idx_purchase_customer ON new_schema.purchase (customer_id);
CREATE INDEX idx_purchase_items_product ON new_schema.purchase_items (product_id);

-- Создание представления (остается без изменений)
CREATE VIEW new_schema.recent_high_value_purchases AS
SELECT c.name  AS customer_name,
       p.date  AS purchase_date,
       p.price AS total_amount
FROM new_schema.purchase p
         JOIN
     new_schema.customer c ON p.customer_id = c.id
WHERE p.price > 1000
ORDER BY p.date DESC
LIMIT 10;