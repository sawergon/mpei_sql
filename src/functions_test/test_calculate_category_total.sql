-- Тест 1: Расчет суммы для категории с товарами
SELECT calculate_category_total(1) AS electronics_total;
-- Ожидаемый результат: 70000 (50000 + 20000)

-- Тест 2: Расчет суммы для пустой категории
SELECT calculate_category_total(11) AS empty_category_total;
-- Ожидаемый результат: 0