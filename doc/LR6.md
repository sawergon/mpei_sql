## Лабораторная работа №6 Доклад по QxORM и пример использования на разработанной базе данных

### Вариант 12


Студ. Сесюкалов А.А. А-14-21.<br>
Рук. Шевченко И.В.


---

# Полное руководство по QxORM для C++ разработчиков

## Оглавление
1. [Введение в QxORM](#введение-в-qxorm)
   1. [Преимущества и недостатки](#преимущества-и-недостатки)
   2. [Установка и настройка](#установка-и-настройка)
   3. [Создание моделей](#создание-моделей)
   4. [Базовые операции CRUD](#базовые-операции-crud)
   5. [Работа со связями](#работа-со-связями)
   6. [Транзакции](#транзакции)
   7. [Оптимизация производительности](#оптимизация-производительности)
   8. [Пример приложения](#пример-приложения)
2. [Разработаное на c++ приложение для моей БД](#разработаное-на-c-приложение-для-моей-бд)

---

## Введение в QxORM

**QxORM** - это мощная ORM (Object-Relational Mapping) библиотека для C++ с интеграцией Qt, которая предоставляет:
- Полноценное отображение объектов на реляционные таблицы
- Поддержку MySQL, PostgreSQL, SQLite и других СУБД
- Автоматическую генерацию SQL-запросов
- Кэширование и оптимизацию запросов

## Преимущества и недостатки

### Преимущества:
- **Полная интеграция с Qt** (использует Qt-типы данных)
- **Поддержка сложных связей** (1-1, 1-Many, Many-Many)
- **Автоматическая генерация SQL** (минимум ручных запросов)
- **Кроссплатформенность** (Windows, Linux, macOS)
- **Поддержка транзакций**
- **Встроенная валидация данных**

### Недостатки:
- **Крутая кривая обучения** (требует понимания ORM концепций)
- **Ограниченное сообщество** (меньше примеров и туториалов)
- **Зависимость от Qt** (не подходит для проектов без Qt)
- **Меньшая производительность** чем у нативных запросов в некоторых сценариях

## Установка и настройка

### Установка через CMake:
```cmake
find_package(QxOrm REQUIRED)
target_link_libraries(your_target PRIVATE QxOrm::QxOrm)
```
### Настройка подключения к MySQL:
```cpp
#include <QxOrm.h>

qx::QxSqlDatabase::getSingleton()->setDriverName("QMYSQL");
qx::QxSqlDatabase::getSingleton()->setDatabaseName("shop_db");
qx::QxSqlDatabase::getSingleton()->setHostName("localhost");
qx::QxSqlDatabase::getSingleton()->setUserName("user");
qx::QxSqlDatabase::getSingleton()->setPassword("pass");
qx::QxSqlDatabase::getSingleton()->setPort(3306);
```

## Создание моделей

### Модель Customer:
```cpp
class Customer {
public:
    long id;
    QString name;
    QDateTime createdAt;
    
    QX_REGISTER_FRIEND_CLASS(Customer)
};

QX_REGISTER_HPP_QX_ORM(Customer, qx::trait::no_base_class_defined, 1)
QX_REGISTER_CPP_QX_ORM(Customer)

namespace qx {
template <> void register_class(QxClass<Customer> &t) {
    t.id(&Customer::id, "id");
    t.data(&Customer::name, "name");
    t.data(&Customer::createdAt, "created_at");
}
}
```

## Базовые операции CRUD

### Создание (Create):
```cpp
Customer_ptr customer(new Customer());
customer->name = "John Doe";
customer->createdAt = QDateTime::currentDateTime();
qx::dao::save(customer);
```

### Чтение (Read):
```cpp
// Получить по ID
Customer_ptr customer = qx::dao::fetch_by_id<Customer>(1);

// Получить все записи с условием
qx_query query("WHERE name LIKE :name ORDER BY created_at DESC");
query.bind(":name", "%John%");
qx::collection<Customer> customers;
qx::dao::fetch_by_query(query, customers);
```

### Обновление (Update):
```cpp
customer->name = "Updated Name";
qx::dao::update(customer);
```

### Удаление (Delete):
```cpp
qx::dao::delete_by_id<Customer>(1);
```

## Работа со связями

### 1-to-Many (Customer → Purchases):
```cpp
class Customer {
    // ...
    QList<QSharedPointer<Purchase>> purchases;
};

// В регистрации:
t.relationOneToMany(&Customer::purchases, "purchases", "customer_id");

// Использование:
Customer_ptr customer;
qx::dao::fetch_by_id_with_relation("purchases", customer, 1);
```

### Many-to-Many (Product ←→ Category):
```cpp
class Product {
    // ...
    QList<QSharedPointer<Category>> categories;
};

// В регистрации:
t.relationManyToMany(&Product::categories, "product_category", 
                   "product_id", "category_id");
```

## Транзакции

```cpp
qx::QxSession session;
session.start();

try {
    Customer_ptr customer(new Customer());
    qx::dao::save_with_session(customer, session);
    
    Purchase_ptr purchase(new Purchase());
    purchase->customer = customer;
    qx::dao::save_with_session(purchase, session);
    
    session.commit();
} catch (const std::exception& e) {
    session.rollback();
    qCritical() << "Transaction failed:" << e.what();
}
```

## Оптимизация производительности

### Пакетные операции:
```cpp
qx::collection<Customer> customers;
// ... заполнение
qx::dao::insert(customers); // Пакетная вставка
```

### Кэширование:
```cpp
// Включение кэша
qx::QxClass<Customer>::getSingleton()->setCacheEnabled(true);

// Использование кэшированного запроса
Customer_ptr customer = qx::dao::fetch_by_id_with_cache<Customer>(1);
```

### Логирование SQL:
```cpp
qx::QxSqlDatabase::getSingleton()->setTraceSqlQuery(true);
```

## Пример приложения

```cpp
int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);
    
    // Настройка БД
    qx::QxSqlDatabase::getSingleton()->setDriverName("QMYSQL");
    // ... остальные параметры
    
    // Создание таблицы
    qx::dao::create_table<Customer>();
    
    // Создание и сохранение объекта
    Customer_ptr customer(new Customer());
    customer->name = "Test User";
    qx::dao::save(customer);
    
    // Чтение с связями
    qx::collection<Customer> customers;
    qx::dao::fetch_all_with_relation("purchases", customers);
    
    // Вывод результатов
    for (const auto& c : customers) {
        qDebug() << "Customer:" << c->name;
        for (const auto& p : c->purchases) {
            qDebug() << " - Purchase:" << p->amount;
        }
    }
    
    return app.exec();
}
```

[официальная документация](https://www.qxorm.com/).

## Разработаное на c++ приложение для моей БД