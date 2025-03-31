-- Тестирование хранимой процедуры calculate_category_totals_for_customer
-- Подготовка тестовых данных

-- Очистка таблиц перед началом тестирования
-- Очистка таблиц перед началом тестирования
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE purchase_items;
TRUNCATE TABLE purchase;
TRUNCATE TABLE product;
TRUNCATE TABLE category;
TRUNCATE TABLE customer;
SET FOREIGN_KEY_CHECKS = 1;

-- Добавление тестовых данных
INSERT INTO category (code, name) VALUES
                                      (1, 'Электроника'),
                                      (2, 'Одежда'),
                                      (3, 'Книги');

INSERT INTO customer (name) VALUES
                                ('Иван Петров'),
                                ('Мария Сидорова'),
                                ('Алексей Иванов'),
                                ('Тестовый Покупатель'); -- Для теста 5

INSERT INTO product (name, price, category_code) VALUES
                                                     ('Ноутбук', 50000, 1),
                                                     ('Смартфон', 30000, 1),
                                                     ('Футболка', 2000, 2),
                                                     ('Джинсы', 5000, 2),
                                                     ('Роман', 500, 3),
                                                     ('Учебник', 800, 3),
                                                     ('Бескатегорийный товар', 1000, NULL); -- Для теста 6

INSERT INTO purchase (date, price, customer_id) VALUES
                                                    ('2023-01-01', 55000, 1),
                                                    ('2023-01-02', 2500, 1),
                                                    ('2023-01-03', 80000, 2),
                                                    ('2023-01-04', 1300, 3);

INSERT INTO purchase_items (amount, product_id, purchase_id, inorder_price) VALUES
                                                                                (1, 1, 1, 50000), -- Ноутбук
                                                                                (1, 3, 1, 2000),  -- Футболка
                                                                                (1, 5, 1, 500),   -- Книга
                                                                                (1, 2, 3, 30000), -- Смартфон
                                                                                (2, 2, 3, 30000), -- 2 смартфона
                                                                                (1, 4, 3, 5000),  -- Джинсы
                                                                                (1, 6, 4, 800),   -- Учебник
                                                                                (1, 5, 4, 500);   -- Роман

-- Тест 1: Проверка для покупателя с ID=1 (Иван Петров)
SELECT '=== Тест 1: Покупатель с ID=1 (Иван Петров) ===' AS test_case;
CALL calculate_category_totals_for_customer(1);
SELECT 'Ожидаемый результат: 3 записи (Электроника 50000, Одежда 2000, Книги 500)' AS expected;

-- Тест 2: Проверка для покупателя с ID=2 (Мария Сидорова)
SELECT '=== Тест 2: Покупатель с ID=2 (Мария Сидорова) ===' AS test_case;
CALL calculate_category_totals_for_customer(2);
SELECT 'Ожидаемый результат: 2 записи (Электроника 90000, Одежда 5000)' AS expected;

-- Тест 3: Проверка для покупателя с ID=3 (Алексей Иванов)
SELECT '=== Тест 3: Покупатель с ID=3 (Алексей Иванов) ===' AS test_case;
CALL calculate_category_totals_for_customer(3);
SELECT 'Ожидаемый результат: 1 запись (Книги 1300)' AS expected;

-- Тест 4: Проверка для несуществующего покупателя
SELECT '=== Тест 4: Несуществующий покупатель (ID=999) ===' AS test_case;
CALL calculate_category_totals_for_customer(999);
SELECT 'Ожидаемый результат: пустой результат (0 записей)' AS expected;

-- Тест 5: Проверка для покупателя без покупок
SELECT '=== Тест 5: Покупатель без покупок (ID=4) ===' AS test_case;
CALL calculate_category_totals_for_customer(4);
SELECT 'Ожидаемый результат: пустой результат (0 записей)' AS expected;

-- Тест 6: Проверка обработки товаров без категории
-- Добавляем покупку товара без категории для покупателя 1
INSERT INTO purchase_items (amount, product_id, purchase_id, inorder_price) VALUES
    (1, (SELECT id FROM product WHERE name = 'Бескатегорийный товар'), 1, 1000);

SELECT '=== Тест 6: Обработка товаров без категории ===' AS test_case;
CALL calculate_category_totals_for_customer(1);
SELECT 'Ожидаемый результат: товар без категории не должен влиять на результат' AS expected;
SELECT 'Должны остаться те же 3 категории, что и в тесте 1' AS expected_details;

-- Проверка итоговых данных для отладки (опционально)
SELECT '=== Проверка итоговых данных ===' AS debug_info;
SELECT c.id, c.name, COUNT(p.id) as purchase_count
FROM customer c LEFT JOIN purchase p ON c.id = p.customer_id
GROUP BY c.id, c.name;

SELECT '=== Тестирование завершено ===' AS final_message;