from pymongo import MongoClient
from enum import Enum
from settings import MONGO_URI,DATABASE_NAME;


client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]

# 选择集合（相当于 SQL 中的表）
articles = db['articles']
calendar = db['calendar']
student_account = db['student_account']
user_calendar = db['user_calendar']
classrooms = db['classrooms']
clubs = db['clubs']

class collectionNames(Enum):
    articles = "articles"
    calendar = "calendar"
    student_account = "student_account"
    user_calendar = "user_calendar"
    classrooms = "classrooms"
    clubs = "clubs"
   
def getCollection(collection: collectionNames):
    if collection == collectionNames.articles:
        return list(articles.find({}, {"_id": 0}))
    elif collection == collectionNames.calendar:
        return list(calendar.find({}, {"_id": 0}))
    elif collection == collectionNames.student_account:
        return list(student_account.find({}, {"_id": 0}))
    elif collection == collectionNames.user_calendar:
        return list(user_calendar.find({}, {"_id": 0}))
    elif collection == collectionNames.classrooms:
        return list(classrooms.find({}, {"_id": 0}))
    elif collection == collectionNames.clubs:
        return list(clubs.find({}, {"_id": 0}))
