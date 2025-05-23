from pymongo import MongoClient
from config import MONGODB_URI, DATABASE_NAME

def get_database():
    client = MongoClient(MONGODB_URI)
    return client[DATABASE_NAME]
