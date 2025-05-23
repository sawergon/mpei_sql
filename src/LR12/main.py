from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from config import DATABASE_NAME
from database import get_database
from models import Category, Customer, Product, Purchase, PurchaseItem

app = FastAPI(title="Shop API", version="1.0.0")

# Настройка CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def startup_db_client():
    get_database()

@app.on_event("shutdown")
def shutdown_db_client():
    pass

@app.on_event("shutdown")
async def shutdown_db_client():
    pass

# Эндпоинты для категорий
@app.get("/api/categories", response_model=list[Category])
async def get_categories():
    db =  get_database()
    categories =  db.categories.find().to_list(length=100)
    return categories

@app.get("/api/categories/{code}", response_model=Category)
async def get_category(code: int):
    db = get_database()
    category = db.categories.find_one({"code": code})
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category

@app.post("/api/categories", response_model=Category)
async def create_category(category: Category):
    db =  get_database()
    db.categories.insert_one(category.dict())
    return category

@app.put("/api/categories/{code}", response_model=Category)
async def update_category(code: int, category: Category):
    db = get_database()
    result = db.categories.update_one(
        {"code": code},
        {"$set": category.dict()}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Category not found")
    return category

@app.delete("/api/categories/{code}")
async def delete_category(code: int):
    db = get_database()
    result = db.categories.delete_one({"code": code})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Category not found")
    return {"message": "Category deleted successfully"}


# Эндпоинты для клиентов
@app.get("/api/customers", response_model=list[Customer])
async def get_customers():
    db = get_database()
    customers = db.customers.find().to_list(length=100)
    return customers


@app.get("/api/customers/{id}", response_model=Customer)
async def get_customer(id: int):
    db = get_database()
    customer = db.customers.find_one({"id": id})
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    return customer


@app.post("/api/customers", response_model=Customer)
async def create_customer(customer: Customer):
    db = get_database()
    db.customers.insert_one(customer.dict())
    return customer


@app.put("/api/customers/{id}", response_model=Customer)
async def update_customer(id: int, customer: Customer):
    db = get_database()
    result = db.customers.update_one(
        {"id": id},
        {"$set": customer.dict()}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Customer not found")
    return customer


@app.delete("/api/customers/{id}")
async def delete_customer(id: int):
    db = get_database()
    result = db.customers.delete_one({"id": id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Customer not found")
    return {"message": "Customer deleted successfully"}


# Эндпоинты для продуктов
@app.get("/api/products", response_model=list[Product])
async def get_products():
    db = get_database()
    products = db.products.find().to_list(length=100)
    return products


@app.get("/api/products/{id}", response_model=Product)
async def get_product(id: int):
    db = get_database()
    product = db.products.find_one({"id": id})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


@app.post("/api/products", response_model=Product)
async def create_product(product: Product):
    db = get_database()
    db.products.insert_one(product.dict())
    return product


@app.put("/api/products/{id}", response_model=Product)
async def update_product(id: int, product: Product):
    db = get_database()
    result = db.products.update_one(
        {"id": id},
        {"$set": product.dict()}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    return product


@app.delete("/api/products/{id}")
async def delete_product(id: int):
    db = get_database()
    result = db.products.delete_one({"id": id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    return {"message": "Product deleted successfully"}


# Эндпоинты для покупок
@app.get("/api/purchases", response_model=list[Purchase])
async def get_purchases():
    db = get_database()
    purchases = db.purchases.find().to_list(length=100)
    return purchases


@app.get("/api/purchases/{id}", response_model=Purchase)
async def get_purchase(id: int):
    db = get_database()
    purchase = db.purchases.find_one({"id": id})
    if not purchase:
        raise HTTPException(status_code=404, detail="Purchase not found")
    return purchase


@app.post("/api/purchases", response_model=Purchase)
async def create_purchase(purchase: Purchase):
    db = get_database()
    db.purchases.insert_one(purchase.dict())
    return purchase


@app.put("/api/purchases/{id}", response_model=Purchase)
async def update_purchase(id: int, purchase: Purchase):
    db = get_database()
    result = db.purchases.update_one(
        {"id": id},
        {"$set": purchase.dict()}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Purchase not found")
    return purchase


@app.delete("/api/purchases/{id}")
async def delete_purchase(id: int):
    db = get_database()
    result = db.purchases.delete_one({"id": id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Purchase not found")
    return {"message": "Purchase deleted successfully"}


# Эндпоинты для позиций покупок
@app.get("/api/purchase_items", response_model=list[PurchaseItem])
async def get_purchase_items():
    db = get_database()
    items = db.purchase_items.find().to_list(length=100)
    return items


@app.get("/api/purchase_items/{id}", response_model=PurchaseItem)
async def get_purchase_item(id: int):
    db = get_database()
    item = db.purchase_items.find_one({"id": id})
    if not item:
        raise HTTPException(status_code=404, detail="Purchase item not found")
    return item


@app.post("/api/purchase_items", response_model=PurchaseItem)
async def create_purchase_item(item: PurchaseItem):
    db = get_database()
    db.purchase_items.insert_one(item.dict())
    return item


@app.put("/api/purchase_items/{id}", response_model=PurchaseItem)
async def update_purchase_item(id: int, item: PurchaseItem):
    db = get_database()
    result = db.purchase_items.update_one(
        {"id": id},
        {"$set": item.dict()}
    )
    if result.modified_count == 0:
        raise HTTPException(status_code=404, detail="Purchase item not found")
    return item


@app.delete("/api/purchase_items/{id}")
async def delete_purchase_item(id: int):
    db = get_database()
    result = db.purchase_items.delete_one({"id": id})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Purchase item not found")
    return {"message": "Purchase item deleted successfully"}


# Эндпоинты для MongoDB запросов
@app.get("/api/queries/query1")
async def get_query1():
    """Получение категорий, купленных пользователем Иван Иванов"""
    db = get_database()
    pipeline = [
        {'$match': {'name': 'Иван Иванов'}},
        {'$lookup': {
            'from': 'purchases',
            'localField': 'id',
            'foreignField': 'customer_id',
            'as': 'purchases'
        }},
        {'$unwind': '$purchases'},
        {'$lookup': {
            'from': 'purchase_items',
            'localField': 'purchases.id',
            'foreignField': 'purchase_id',
            'as': 'items'
        }},
        {'$unwind': '$items'},
        {'$lookup': {
            'from': 'products',
            'localField': 'items.product_id',
            'foreignField': 'id',
            'as': 'products'
        }},
        {'$unwind': '$products'},
        {'$lookup': {
            'from': 'categories',
            'localField': 'products.category_code',
            'foreignField': 'code',
            'as': 'categories'
        }},
        {'$unwind': '$categories'},
        {'$group': {
            '_id': '$categories.name',
            'count': {'$sum': 1}
        }},
        {'$project': {
            '_id': 0,
            'category_name': '$_id',
            'count': 1
        }}
    ]
    result = db.customers.aggregate(pipeline)
    return list(result)


@app.get("/api/queries/query2")
async def get_query2():
    """Продажи по категориям за прошлый год"""
    from datetime import datetime
    current_year = datetime.now().year
    last_year = current_year - 1

    db = get_database()
    pipeline = [
        {'$match': {
            'date': {'$gte': datetime(last_year, 1, 1), '$lt': datetime(current_year, 1, 1)}
        }},
        {'$lookup': {
            'from': 'purchase_items',
            'localField': 'id',
            'foreignField': 'purchase_id',
            'as': 'items'
        }},
        {'$unwind': '$items'},
        {'$lookup': {
            'from': 'products',
            'localField': 'items.product_id',
            'foreignField': 'id',
            'as': 'products'
        }},
        {'$unwind': '$products'},
        {'$lookup': {
            'from': 'categories',
            'localField': 'products.category_code',
            'foreignField': 'code',
            'as': 'categories'
        }},
        {'$unwind': '$categories'},
        {'$group': {
            '_id': {
                'category_name': '$categories.name',
                'month': {'$month': '$date'},
                'year': {'$year': '$date'}
            },
            'total_sales': {'$sum': {'$multiply': ['$items.amount', '$items.inorder_price']}}
        }},
        {'$project': {
            '_id': 0,
            'category_name': '$_id.category_name',
            'month': '$_id.month',
            'year': '$_id.year',
            'total_sales': 1
        }}
    ]
    result = db.purchases.aggregate(pipeline)
    return list(result)


@app.get("/api/queries/query3")
async def get_query3():
    """Топ-5 продуктов по количеству продаж"""
    db = get_database()
    pipeline = [
        {'$lookup': {
            'from': 'purchase_items',
            'localField': 'id',
            'foreignField': 'product_id',
            'as': 'items'
        }},
        {'$unwind': '$items'},
        {'$group': {
            '_id': '$name',
            'amount': {'$sum': '$items.amount'}
        }},
        {'$sort': {'amount': -1}},
        {'$limit': 5},
        {'$project': {
            '_id': 0,
            'name': '$_id',
            'amount': 1
        }}
    ]
    result = db.products.aggregate(pipeline)
    return list(result)


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
