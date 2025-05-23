from pydantic import BaseModel
from typing import Optional

class Category(BaseModel):
    code: int
    name: str

class Customer(BaseModel):
    id: int
    name: str

class Product(BaseModel):
    id: int
    name: str
    price: float
    category_code: int

class Purchase(BaseModel):
    id: int
    customer_id: int
    date: str
    price: float

class PurchaseItem(BaseModel):
    purchase_id: int
    product_id: int
    amount: int
    inorder_price: float
