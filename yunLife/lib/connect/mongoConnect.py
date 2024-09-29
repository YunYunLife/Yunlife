from pymongo import MongoClient
from enum import Enum

# 连接到 MongoDB 服务器
client = MongoClient("mongodb+srv://ywu1123:1017@cluster0.nqjyzwh.mongodb.net/")

# 选择数据库（如果不存在会自动创建）
db = client['yuntech_db']

# 选择集合（相当于 SQL 中的表）
articles = db['articles']
calendar = db['calendar']
classrooms = db['classrooms']
clubs = db['clubs']

class collectionNames(Enum):
    articles = "articles"
    calendar = "calendar"
    classrooms = "classrooms"
    clubs = "clubs"

def getCollection(collection: collectionNames):
    match collection:
        case collectionNames.articles:
            return list(articles.find({}, {"_id": 0}))
        case collectionNames.calendar:
            return list(calendar.find({}, {"_id": 0}))
        case collectionNames.classrooms:
            return list(classrooms.find({}, {"_id": 0}))
        case collectionNames.clubs:
            return list(clubs.find({}, {"_id": 0}))
        case _:
            return "not find collection"
