-- Подготовка данных
INSERT INTO category (code, name) VALUES (10, 'Тестовая категория');
INSERT INTO product (name, price, category_code) VALUES ('Тестовый товар', 1000, 10);

-- Попытка удалить категорию с товарами (должна вызвать ошибку)
DELETE FROM category WHERE code = 10;
-- Ожидаемый результат: ошибка "Нельзя удалить категорию с товарами"

-- Удаление товара и затем категории (должно работать)
DELETE FROM product WHERE category_code = 10;
DELETE FROM category WHERE code = 10;
-- Ожидаемый результат: успешное удаление

-- Попытка удалить пустую категорию
INSERT INTO category (code, name) VALUES (11, 'Пустая категория');
DELETE FROM category WHERE code = 11;
-- Ожидаемый результат: успешное удаление