## Отчет по лабораторной работе №3
## По предмету: «Базы данных и информационные системы»
### Вариант 12


Студ. Сесюкалов А.А. А-14-21.<br>
Рук. Шевченко И.В.


---

## Функции
- [подсчет количества купленного в категории](../src/functions/add_product.sql)
- [подсчет общего количества купленного для покупателя](../src/functions/get_customer_purchase_total.sql)
## Процедуры
- [добавление нового товара](../src/functions/add_product.sql)
- [создание покупки](../src/functions/make_purchase.sql)
## Триггеры
- [запрет на удаление категории](../src/triggers/prevent_category_deletion.sql)
- [установка цены товара при добавлении в корзину](../src/triggers/set_product_price_on_cart_insert.sql)