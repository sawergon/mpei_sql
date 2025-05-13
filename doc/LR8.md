# Лабораторная работа №8: Пользователи, роли и SSL

### 1. Создание пользователей и ролей

1. Создаем две роли: analyst\_role и manager\_role

    * CREATE ROLE analyst\_role;
    * CREATE ROLE manager\_role;

2. Создаем двух пользователей: analyst\_user и manager\_user с паролями

    * CREATE USER 'analyst\_user'@'%' IDENTIFIED BY 'analyst\_pass';
    * CREATE USER 'manager\_user'@'%' IDENTIFIED BY 'manager\_pass';

3. Присваиваем роли пользователям

    * GRANT analyst\_role TO 'analyst\_user'@'%';
    * GRANT manager\_role TO 'manager\_user'@'%';

### 2. Назначение привилегий на уровне таблиц и столбцов

#### analyst\_role (только выборка данных)

* Разрешаем SELECT на все столбцы таблицы product

    * GRANT SELECT ON testdb.product TO analyst\_role;

* Разрешаем SELECT только на столбцы id и name таблицы customer

    * GRANT SELECT (id, name) ON testdb.customer TO analyst\_role;

#### manager\_role (полный доступ к product и выполнение процедур)

* Разрешаем полный доступ к таблице product

    * GRANT SELECT, INSERT, UPDATE, DELETE ON testdb.product TO manager\_role;

* Разрешаем выполнение хранимой процедуры calculate\_discount

    * GRANT EXECUTE ON PROCEDURE testdb.calculate\_discount TO manager\_role;

### 3. Демонстрация запросами

* Проверяем привилегии analyst\_user:

    * Вход под analyst\_user и выполнение SELECT \* FROM product; — успешно
    * Попытка INSERT INTO product — ошибка: недостаточно привилегий
    * SELECT id, name FROM customer; — успешно
    * SELECT price FROM customer; — ошибка: столбец недоступен

* Проверяем привилегии manager\_user:

    * Вход под manager\_user и выполнение UPDATE product SET price=price\*0.9; — успешно
    * Вызов CALL calculate\_discount(1, 0.1); — успешно

### 4. Настройка SSL и проверка защищенного подключения

1. Генерация сертификатов на сервере и клиенте (self-signed)
2. Настройка параметров в my.cnf на сервере:

    * \[mysqld]
    * ssl-ca=ca.pem
    * ssl-cert=server-cert.pem
    * ssl-key=server-key.pem
3. Перезапуск сервера MySQL
4. Настройка клиента:

    * mysql --ssl-ca=ca.pem --ssl-cert=client-cert.pem --ssl-key=client-key.pem -u analyst\_user -p
5. Проверка защищенного подключения: SHOW STATUS LIKE 'Ssl\_cipher'; — вывод не пустой, соединение по SSL.