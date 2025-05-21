import pymongo
from datetime import datetime

# Initialize MongoDB client
client = pymongo.MongoClient('mongodb://localhost:27017')
db = client['shop_db']

def query1():
    """
    Equivalent to:
    SELECT category.name
    FROM customer
             JOIN purchase ON customer.id = purchase.customer_id
             JOIN purchase_items ON purchase.id = purchase_items.purchase_id
             JOIN product ON product.id = purchase_items.product_id
             JOIN category ON category.code = product.category_code
    WHERE customer.name = 'иван иванов'
    GROUP BY category.name;
    """
    pipeline = [
        # Start from customer collection
        {'$match': {'name': 'Иван Иванов'}},
        # Join with purchases
        {'$lookup': {
            'from': 'purchases',
            'localField': 'id',
            'foreignField': 'customer_id',
            'as': 'purchases'
        }},
        # Unwind purchases array
        {'$unwind': '$purchases'},
        # Join with purchase_items
        {'$lookup': {
            'from': 'purchase_items',
            'localField': 'purchases.id',
            'foreignField': 'purchase_id',
            'as': 'items'
        }},
        # Unwind items array
        {'$unwind': '$items'},
        # Join with products
        {'$lookup': {
            'from': 'products',
            'localField': 'items.product_id',
            'foreignField': 'id',
            'as': 'products'
        }},
        # Unwind products array
        {'$unwind': '$products'},
        # Join with categories
        {'$lookup': {
            'from': 'categories',
            'localField': 'products.category_code',
            'foreignField': 'code',
            'as': 'categories'
        }},
        # Unwind categories array
        {'$unwind': '$categories'},
        # Group by category name
        {'$group': {
            '_id': '$categories.name',
            'count': {'$sum': 1}
        }},
        # Format output
        {'$project': {
            '_id': 0,
            'category_name': '$_id',
            'count': 1
        }}
    ]
    
    result = db.customers.aggregate(pipeline)
    print("\nQuery 1 - Categories purchased by 'иван иванов':")
    for item in result:
        print(item)

def query2():
    """
    Equivalent to:
    SELECT c.name as category_name,
           monthname(p.date) as month_name,
           sum(pi.amount * pi.inorder_price) as total_sales
    FROM purchase p
             JOIN purchase_items pi ON p.id = pi.purchase_id
             JOIN product pr ON pi.product_id = pr.id
             JOIN category c ON pr.category_code = c.code
    WHERE year(p.date) = year(curdate()) - 1
    GROUP BY c.name, year(p.date), month_name
    ORDER BY month_name;
    """
    current_year = datetime.now().year
    last_year = current_year - 1
    
    pipeline = [
        # Start from purchases
        {'$match': {'date': {'$gte': datetime(last_year, 1, 1), '$lt': datetime(current_year, 1, 1)}}},
        # Join with purchase_items
        {'$lookup': {
            'from': 'purchase_items',
            'localField': 'id',
            'foreignField': 'purchase_id',
            'as': 'items'
        }},
        # Unwind items array
        {'$unwind': '$items'},
        # Join with products
        {'$lookup': {
            'from': 'products',
            'localField': 'items.product_id',
            'foreignField': 'id',
            'as': 'products'
        }},
        # Unwind products array
        {'$unwind': '$products'},
        # Join with categories
        {'$lookup': {
            'from': 'categories',
            'localField': 'products.category_code',
            'foreignField': 'code',
            'as': 'categories'
        }},
        # Unwind categories array
        {'$unwind': '$categories'},
        # Calculate total sales
        {'$group': {
            '_id': {
                'category': '$categories.name',
                'month': {'$month': '$date'},
                'year': {'$year': '$date'}
            },
            'total_sales': {'$sum': {'$multiply': ['$items.amount', '$items.inorder_price']}},
            'month_name': {'$first': {'$dateToString': {'date': '$date', 'format': '%B'}}}
        }},
        # Sort by month name
        {'$sort': {'month_name': 1}},
        # Format output
        {'$project': {
            '_id': 0,
            'category_name': '$_id.category',
            'month_name': 1,
            'year': '$_id.year',
            'total_sales': 1
        }}
    ]
    
    result = db.purchases.aggregate(pipeline)
    print("\nQuery 2 - Monthly sales by category for last year:")
    for item in result:
        print(item)

def query3():
    """
    Equivalent to:
    SELECT product.name as name,
           sum(purchase_items.amount) as amount
    FROM product
    JOIN purchase_items ON product.id = purchase_items.product_id
    GROUP BY name
    ORDER BY amount DESC
    LIMIT 5;
    """
    pipeline = [
        # Start from purchase_items
        {'$lookup': {
            'from': 'products',
            'localField': 'product_id',
            'foreignField': 'id',
            'as': 'products'
        }},
        # Unwind products array
        {'$unwind': '$products'},
        # Group by product name
        {'$group': {
            '_id': '$products.name',
            'total_amount': {'$sum': '$amount'}
        }},
        # Sort by total amount in descending order
        {'$sort': {'total_amount': -1}},
        # Limit to top 5
        {'$limit': 5},
        # Format output
        {'$project': {
            '_id': 0,
            'name': '$_id',
            'amount': '$total_amount'
        }}
    ]
    
    result = db.purchase_items.aggregate(pipeline)
    print("\nQuery 3 - Top 5 products by quantity sold:")
    for item in result:
        print(item)

if __name__ == '__main__':
    query1()
    query2()
    query3()