-- Тест 1: Добавление нового товара
CALL add_product('Планшет', 25000, 1, @new_product_id);
SELECT @new_product_id AS new_id, name, price FROM product WHERE id = @new_product_id;
-- Ожидаемый результат: новый ID, имя 'Планшет', цена 25000

-- Тест 2: Попытка добавить товар в несуществующую категорию
CALL add_product('Неизвестный товар', 100, 999, @bad_product_id);
-- Ожидаемое поведение: ошибка внешнего ключа