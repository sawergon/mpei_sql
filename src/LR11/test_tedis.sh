#!/bin/bash

# Проверка соединения с Redis
echo "Проверка соединения с Redis..."
redis-cli ping
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось подключиться к Redis"
    exit 1
fi

# Тестирование строк
echo -e "\nТестирование строк..."
redis-cli SET user:1:name "Иван Иванов"
redis-cli SET user:1:age 30
echo "Получаем имя: $(redis-cli GET user:1:name)"
echo "Получаем возраст: $(redis-cli GET user:1:age)"

# Тестирование списков
echo -e "\nТестирование списков..."
redis-cli DEL users
redis-cli RPUSH users "Алексей"
redis-cli RPUSH users "Мария"
redis-cli RPUSH users "Анна"
echo "Количество пользователей: $(redis-cli LLEN users)"
echo "Список пользователей: $(redis-cli LRANGE users 0 -1)"

# Тестирование множеств
echo -e "\nТестирование множеств..."
redis-cli DEL fruits
redis-cli SADD fruits "яблоко"
redis-cli SADD fruits "банан"
redis-cli SADD fruits "апельсин"
echo "Фрукты в множестве: $(redis-cli SMEMBERS fruits)"
echo "Проверяем наличие яблока: $(redis-cli SISMEMBER fruits яблоко)"
echo "Проверяем наличие груши: $(redis-cli SISMEMBER fruits груша)"

echo -e "\nВсе тесты завершены успешно!"