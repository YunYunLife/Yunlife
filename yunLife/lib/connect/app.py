from flask import Flask, jsonify, request, make_response,Response
from flask_cors import CORS
import json
from pymongo import MongoClient
from mongoConnect import getCollection, collectionNames
from chatgpt_handler import process_user_input, update_memory
from settings import MONGO_URI,DATABASE_NAME


app = Flask(__name__)
CORS(app)

client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]

@app.route('/')
def get_home():
    return "hello, this is yunlife server"

@app.route('/articles', methods=['GET'])
def get_articles():
    result = getCollection(collectionNames.articles)
    return saveChinese(result)

@app.route('/calendar', methods=['GET'])
def get_calendar():
    result = getCollection(collectionNames.calendar)
    return saveChinese(result)
  
@app.route('/user_calendar', methods=['GET'])
def get_usercalendar():
    result = getCollection(collectionNames.user_calendar)
    return saveChinese(result)
  
@app.route('/userdata_upload', methods=['POST'])
def userdata_upload():
    event_data = request.json
    try:
        collection = db['user_calendar']
        collection.insert_one(event_data)
        return jsonify({"message": "Event added successfully!"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route('/classrooms', methods=['GET'])
def get_classrooms():
    result = getCollection(collectionNames.classrooms)
    return saveChinese(result)

@app.route('/clubs', methods=['GET'])
def get_clubs():
    result = getCollection(collectionNames.clubs)
    return saveChinese(result)

@app.route('/elearing', methods=['GET'])
def get_elearing_articles():  
    result = getCollection(collectionNames.elearing)
    return saveChinese(result)

@app.route('/business_reality', methods=['GET'])
def get_business_reality_articles():  
    result = getCollection(collectionNames.business_reality)
    return saveChinese(result)

@app.route('/business_online', methods=['GET'])
def get_business_online_articles(): 
    result = getCollection(collectionNames.business_online)
    return saveChinese(result)

@app.route('/siliconvalley', methods=['GET'])
def get_siliconvalley_articles():  
    result = getCollection(collectionNames.siliconvalley)
    return saveChinese(result)

@app.route('/university_course', methods=['GET'])
def get_university_course_articles(): 
    result = getCollection(collectionNames.university_course)
    return saveChinese(result)

@app.route('/university_course_list', methods=['GET'])
def get_university_course_list_articles():  
    result = getCollection(collectionNames.university_course_list)
    return saveChinese(result)

def saveChinese(data):
    response = make_response(json.dumps({'greetings': data}, ensure_ascii=False))
    response.headers['Content-Type'] = 'application/json; charset=utf-8'
    return response

@app.route('/ask', methods=['POST'])
def ask():
    data = request.json
    user_input = data.get('prompt', '').lower()
    
    response = process_user_input(user_input)
    
    update_memory(user_input, response)
    
    return jsonify({'response': response})

if __name__ == "__main__":
    app.run(debug=True)
    
