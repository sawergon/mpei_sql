import pymongo
from datetime import datetime, timedelta
import random

# Initialize MongoDB client
client = pymongo.MongoClient('mongodb://localhost:27017')
db = client['shop_db']

# Function to clear existing data in collections
def clear_collections():
    db['categories'].delete_many({})
    db['customers'].delete_many({})
    db['products'].delete_many({})
    db['purchases'].delete_many({})
    db['purchase_items'].delete_many({})

# Clear collections before populating with new test data
clear_collections()

# Create collections with indexes
if 'categories' not in db.list_collection_names():
    categories = db.create_collection('categories')
    categories.create_index([('code', pymongo.ASCENDING)], unique=True)
else:
    categories = db['categories']

if 'customers' not in db.list_collection_names():
    customers = db.create_collection('customers')
    customers.create_index([('id', pymongo.ASCENDING)], unique=True)
else:
    customers = db['customers']

if 'products' not in db.list_collection_names():
    products = db.create_collection('products')
    products.create_index([('id', pymongo.ASCENDING)], unique=True)
    products.create_index([('category_code', pymongo.ASCENDING)])
else:
    products = db['products']

if 'purchases' not in db.list_collection_names():
    purchases = db.create_collection('purchases')
    purchases.create_index([('id', pymongo.ASCENDING)], unique=True)
    purchases.create_index([('customer_id', pymongo.ASCENDING)])
else:
    purchases = db['purchases']

if 'purchase_items' not in db.list_collection_names():
    purchase_items = db.create_collection('purchase_items')
    purchase_items.create_index([('purchase_id', pymongo.ASCENDING)])
    purchase_items.create_index([('product_id', pymongo.ASCENDING)])
else:
    purchase_items = db['purchase_items']

# Sample data
# Categories
categories_data = [
    {'code': 1, 'name': 'Электроника'},
    {'code': 2, 'name': 'Одежда'},
    {'code': 3, 'name': 'Книги'},
    {'code': 4, 'name': 'Мебель'},
    {'code': 5, 'name': 'Продукты'}
]

# Customers
customers_data = [
    {'id': 1, 'name': 'Иван Иванов'},
    {'id': 2, 'name': 'Петр Петров'},
    {'id': 3, 'name': 'Анна Смирнова'},
    {'id': 4, 'name': 'Мария Кузнецова'},
    {'id': 5, 'name': 'Алексей Соколов'},
    {'id': 6, 'name': 'Елена Попова'}
]

# Products
products_data = [
    {'id': 1, 'name': 'Смартфон', 'price': 999.99, 'category_code': 1},
    {'id': 2, 'name': 'Ноутбук', 'price': 1499.99, 'category_code': 1},
    {'id': 3, 'name': 'Футболка', 'price': 29.99, 'category_code': 2},
    {'id': 4, 'name': 'Джинсы', 'price': 49.99, 'category_code': 2},
    {'id': 5, 'name': 'Программирование для начинающих', 'price': 39.99, 'category_code': 3},
    {'id': 6, 'name': 'Кофейный столик', 'price': 199.99, 'category_code': 4},
    {'id': 7, 'name': 'Шоколад', 'price': 4.99, 'category_code': 5},
    {'id': 8, 'name': 'Наушники', 'price': 199.99, 'category_code': 1},
    {'id': 9, 'name': 'Платье', 'price': 79.99, 'category_code': 2},
    {'id': 10, 'name': 'Роман', 'price': 29.99, 'category_code': 3},
    {'id': 11, 'name': 'Кресло', 'price': 149.99, 'category_code': 4},
    {'id': 12, 'name': 'Молоко', 'price': 2.99, 'category_code': 5}
]

# Insert categories
categories.insert_many(categories_data)

# Insert customers
customers.insert_many(customers_data)

# Insert products
products.insert_many(products_data)

# Generate purchases for last year and this year
this_year = datetime.now().year
last_year = this_year - 1

# Function to get next purchase ID
def get_next_purchase_id():
    last_purchase = purchases.find_one(sort=[('id', pymongo.DESCENDING)])
    if last_purchase:
        return last_purchase['id'] + 1
    return 1

# Generate purchases for last year
for month in range(1, 13):
    for day in range(1, 29):  # Using 28 days to avoid date issues
        date = datetime(last_year, month, day)
        
        # Create 2-4 purchases per day
        for _ in range(random.randint(2, 4)):
            customer_id = random.randint(1, 6)
            purchase_id = get_next_purchase_id()
            purchase = {
                'id': purchase_id,
                'date': date,
                'price': 0.0,
                'customer_id': customer_id
            }
            
            purchases.insert_one(purchase)
            
            # Add 1-5 items to the purchase
            purchase_items_data = []
            for _ in range(random.randint(1, 5)):
                product = random.choice(products_data)
                amount = random.randint(1, 5)
                inorder_price = product['price']
                
                purchase_items_data.append({
                    'amount': amount,
                    'product_id': product['id'],
                    'purchase_id': purchase_id,
                    'inorder_price': inorder_price
                })
                
                # Update purchase price
                purchases.update_one(
                    {'id': purchase_id},
                    {'$inc': {'price': amount * inorder_price}}
                )
            
            purchase_items.insert_many(purchase_items_data)

# Generate additional purchases for this year
for month in range(1, 13):
    for day in range(1, 29):
        date = datetime(this_year, month, day)
        
        # Create 2-4 purchases per day
        for _ in range(random.randint(2, 4)):
            customer_id = random.randint(1, 6)
            purchase_id = get_next_purchase_id()
            purchase = {
                'id': purchase_id,
                'date': date,
                'price': 0.0,
                'customer_id': customer_id
            }
            
            purchases.insert_one(purchase)
            
            # Add 1-5 items to the purchase
            purchase_items_data = []
            for _ in range(random.randint(1, 5)):
                product = random.choice(products_data)
                amount = random.randint(1, 5)
                inorder_price = product['price']
                
                purchase_items_data.append({
                    'amount': amount,
                    'product_id': product['id'],
                    'purchase_id': purchase_id,
                    'inorder_price': inorder_price
                })
                
                # Update purchase price
                purchases.update_one(
                    {'id': purchase_id},
                    {'$inc': {'price': amount * inorder_price}}
                )
            
            purchase_items.insert_many(purchase_items_data)

print("Database populated with test data")
