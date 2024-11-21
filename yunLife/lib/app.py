from flask import Flask, jsonify, request, make_response, Response
from flask_cors import CORS
import json
from pymongo import MongoClient
from mongoConnect import getCollection, collectionNames
from chatgpt_handler import process_user_input
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

@app.route('/student_account', methods=['GET'])
def get_student_account():
    result = getCollection(collectionNames.student_account)
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

@app.route('/clubs', methods=['GET'])
def get_clubs():
    result = getCollection(collectionNames.clubs)
    return saveChinese(result)

def saveChinese(data):
    response = make_response(json.dumps({'greetings': data}, ensure_ascii=False))
    response.headers['Content-Type'] = 'application/json; charset=utf-8'
    return response

@app.route('/ask', methods=['POST'])
def ask():
    data = request.json
    user_input = data.get('prompt', '').strip().lower()
    # 普通的 ChatGPT 問答處理
    response = process_user_input(user_input,)
    return jsonify({'response': response}), 200


if __name__ == "__main__":
    app.run(debug=True)
    
