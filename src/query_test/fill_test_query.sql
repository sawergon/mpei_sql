-- очистка таблиц
delete from purchase_items;
delete from purchase;
delete from product;
delete from customer;
delete from category;

-- заполнение таблицы категорий
insert into category (code, name) values
    (1, 'электроника'),
    (2, 'одежда'),
    (3, 'книги'),
    (4, 'игрушки');

-- заполнение таблицы клиентов
insert into customer (id, name) values
    (1, 'иван иванов'),
    (2, 'петр петров'),
    (3, 'анна сидорова'),
    (4, 'мария смирнова');

-- заполнение таблицы товаров
insert into product (id, name, price, category_code) values
    (1, 'смартфон', 20000, 1),
    (2, 'ноутбук', 50000, 1),
    (3, 'футболка', 1000, 2),
    (4, 'джинсы', 3000, 2),
    (5, 'книга ''python для начинающих''', 1500, 3),
    (6, 'книга ''искусство программирования''', 2500, 3),
    (7, 'конструктор lego', 3500, 4),
    (8, 'плюшевый мишка', 700, 4);

-- заполнение таблицы покупок
insert into purchase (id, date, price, customer_id) values
    (1, '2024-03-08 09:45:41', 20000, 1),
    (2, '2024-03-08 09:45:41', 1000, 2),
    (3, '2025-03-08 09:45:41', 6000, 3),
    (4, '2025-03-08 09:45:41', 4500, 4),
    (5, '2025-03-08 09:45:41', 6000, 3),
    (6, '2025-03-08 09:45:41', 1500, 1),
    (7, '2024-01-08 09:45:41', 12000, 2),
    (8, '2024-02-08 09:45:41', 9000, 4),
    (9, '2024-04-08 09:45:41', 21000, 1),
    (10, '2024-05-08 09:45:41', 16000, 3),
    (11, '2024-06-08 09:45:41', 14000, 1),
    (12, '2024-07-08 09:45:41', 19000, 2),
    (13, '2024-08-08 09:45:41', 22000, 3),
    (14, '2024-09-08 09:45:41', 17000, 1),
    (15, '2024-10-08 09:45:41', 19500, 3),
    (16, '2024-11-08 09:45:41', 24000, 4),
    (17, '2024-12-08 09:45:41', 15500, 1);

-- заполнение таблицы элементов покупок
insert into purchase_items (amount, product_id, purchase_id, inorder_price) values
    (1, 1, 1, 20000),
    (1, 3, 2, 1000),
    (2, 4, 3, 3000),
    (1, 7, 4, 3500),
    (1, 8, 4, 700),
    (2, 4, 5, 3000),
    (1, 5, 6, 1500),
    (1, 1, 7, 12000),
    (1, 4, 8, 9000),
    (2, 1, 9, 21000),
    (2, 3, 10, 16000),
    (2, 2, 11, 14000),
    (1, 1, 12, 19000),
    (1, 2, 12, 6000),
    (2, 3, 13, 22000),
    (2, 4, 13, 12000),
    (1, 1, 14, 17000),
    (2, 3, 15, 19500),
    (1, 4, 16, 24000),
    (1, 5, 17, 15500),
    (1, 7, 17, 3500);