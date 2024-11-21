from pymongo import MongoClient
from enum import Enum
from settings import campusai_url,MONGO_URI,DATABASE_NAME;


client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]

# 选择集合（相当于 SQL 中的表）
articles = db['articles']
calendar = db['calendar']
student_account = db['student_account']
user_calendar = db['user_calendar']
classrooms = db['classrooms']
clubs = db['clubs']
elearing = db['elearing']
business_reality = db['business_reality']
business_online = db['business_online']
siliconvalley = db['siliconvalley']
university_course = db['university_course'] 
university_course_list = db['university_course_list']

class collectionNames(Enum):
    articles = "articles"
    calendar = "calendar"
    student_account = "student_account"
    user_calendar = "user_calendar"
    classrooms = "classrooms"
    clubs = "clubs"
    elearing = "elearing"
    business_reality = "business_reality"
    business_online = "business_online"
    siliconvalley = "siliconvalley"
    university_course = "university_course"
    university_course_list = "university_course_list"

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
    elif collection == collectionNames.elearing:
        return list(elearing.find({}, {"_id": 0}))
    elif collection == collectionNames.business_reality:
        return list(business_reality.find({}, {"_id": 0}))
    elif collection == collectionNames.business_online:
        return list(business_online.find({}, {"_id": 0}))
    elif collection == collectionNames.siliconvalley:
        return list(siliconvalley.find({}, {"_id": 0}))
    elif collection == collectionNames.university_course:
        return list(university_course.find({}, {"_id": 0}))
    elif collection == collectionNames.university_course_list:
        return list(university_course_list.find({}, {"_id": 0}))
