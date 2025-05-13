## Лабораторная работа №7 Транзакции

### Вариант 12


Студ. Сесюкалов А.А. А-14-21.<br>
Рук. Шевченко И.В.


---

## 1. REPEATABLE READ (MVCC)

Для всех примеров уровень изоляции устанавливается командой: SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

### 1.1. Потерянное обновление (Lost Update)

| Шаг | T1                                                       | T2                                                                       |
|-----|----------------------------------------------------------|--------------------------------------------------------------------------|
| 1   | BEGIN;                                                   |                                                                          |
| 2   | SELECT price FROM product WHERE id=1;  -- возвращает 100 | BEGIN;                                                                   |
| 3   | UPDATE product SET price = price + 10 WHERE id=1;        | SELECT price FROM product WHERE id=1;  -- возвращает 100 (снэпшот)       |
| 4   | COMMIT;                                                  | UPDATE product SET price = price + 20 WHERE id=1;  -- ждет разблокировки |
| 5   |                                                          | COMMIT;  -- после COMMIT T1 итоговая цена = 120                          |

**Вывод:** T2 ожидает освобождения блокировки T1, поэтому потерянное обновление не происходит.

### 1.2. Грязное чтение (Dirty Read)

| Шаг | T1                                                        | T2                                                       |
|-----|-----------------------------------------------------------|----------------------------------------------------------|
| 1   | BEGIN;                                                    | BEGIN;                                                   |
| 2   | UPDATE product SET price = 500 WHERE id=2;  -- без COMMIT | SELECT price FROM product WHERE id=2;  -- возвращает 200 |
| 3   | (изменения не зафиксированы)                              | ROLLBACK;                                                |

**Вывод:** T2 видит старое значение из своего снэпшота, грязное чтение невозможно.

### 1.3. Неповторяемое чтение (Non-Repeatable Read)

| Шаг | T1                                                       | T2                                         |
|-----|----------------------------------------------------------|--------------------------------------------|
| 1   | BEGIN;                                                   | BEGIN;                                     |
| 2   | SELECT price FROM product WHERE id=3;  -- возвращает 300 | UPDATE product SET price = 350 WHERE id=3; |
| 3   |                                                          | COMMIT;                                    |
| 4   | SELECT price FROM product WHERE id=3;  -- возвращает 300 |                                            |
| 5   | COMMIT;                                                  |                                            |

**Вывод:** повторные SELECT в T1 возвращают одно и то же значение, неповторяемого чтения нет.

### 1.4. Фантомы (Phantom Read)

| Шаг | T1                                                                | T2                                                  |
|-----|-------------------------------------------------------------------|-----------------------------------------------------|
| 1   | BEGIN;                                                            | BEGIN;                                              |
| 2   | SELECT COUNT(\*) FROM product WHERE price < 100;  -- возвращает 5 | INSERT INTO product (name, price) VALUES ('X', 50); |
| 3   |                                                                   | COMMIT;                                             |
| 4   | SELECT COUNT(\*) FROM product WHERE price < 100;  -- возвращает 5 |                                                     |
| 5   | COMMIT;                                                           |                                                     |

**Вывод:** T1 не видит вставку T2, фантомные чтения отсутствуют.

---

## 2. REPEATABLE READ + LOCK IN SHARE MODE

В сеансе T1, помимо установки уровня изоляции, используется LOCK IN SHARE MODE для чтения.

### 2.1. Потерянное обновление

| Шаг | T1                                                               | T2                                                                       |
|-----|------------------------------------------------------------------|--------------------------------------------------------------------------|
| 1   | SELECT price FROM product WHERE id=1 LOCK IN SHARE MODE;  -- 100 |                                                                          |
| 2   | UPDATE product SET price = price + 10 WHERE id=1;                | UPDATE product SET price = price + 20 WHERE id=1;  -- ждет разблокировки |
| 3   | COMMIT;                                                          |                                                                          |
| 4   |                                                                  | COMMIT;  -- после COMMIT T1 итоговая цена = 120                          |

**Вывод:** оба обновления выполняются последовательно, потерянное обновление исключено.

### 2.2. Грязное чтение (Dirty Read)

| Шаг | T1                                                               | T2                                                       |
|-----|------------------------------------------------------------------|----------------------------------------------------------|
| 1   | SELECT price FROM product WHERE id=2 LOCK IN SHARE MODE;  -- 200 | SELECT price FROM product WHERE id=2;  -- возвращает 200 |
| 2   | UPDATE product SET price = 500 WHERE id=2;  -- без COMMIT        | ROLLBACK;                                                |

**Вывод:** грязное чтение блокируется — T2 не видит незавершенные изменения T1.

### 2.3. Неповторяемое чтение (Non-Repeatable Read)

| Шаг | T1                                                               | T2                                         |
|-----|------------------------------------------------------------------|--------------------------------------------|
| 1   | SELECT price FROM product WHERE id=3 LOCK IN SHARE MODE;  -- 300 | UPDATE product SET price = 350 WHERE id=3; |
| 2   | SELECT price FROM product WHERE id=3 LOCK IN SHARE MODE;  -- 300 | COMMIT;                                    |
| 3   | COMMIT;                                                          |                                            |

**Вывод:** повторное чтение возвращает то же значение.

### 2.4. Фантомы (Phantom Read)

| Шаг | T1                                                                        | T2                                                  |
|-----|---------------------------------------------------------------------------|-----------------------------------------------------|
| 1   | SELECT COUNT(\*) FROM product WHERE price < 100 LOCK IN SHARE MODE;  -- 5 | INSERT INTO product (name, price) VALUES ('Y', 50); |
| 2   | SELECT COUNT(\*) FROM product WHERE price < 100 LOCK IN SHARE MODE;  -- 5 | COMMIT;                                             |
| 3   | COMMIT;                                                                   |                                                     |

**Вывод:** фантомные чтения исключены благодаря диапазонным блокировкам.

---

**Заключение:** оба подхода устраняют все четыре типа аномалий для таблицы `product`.
