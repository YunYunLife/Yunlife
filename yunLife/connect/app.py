from flask import Flask, jsonify, make_response
import json
from mongoConnect import getCollection, collectionNames

app = Flask(__name__)

@app.route('/articles', methods=['GET'])
def get_articles():
    result = getCollection(collectionNames.articles)
    data = {'greetings': result}
    return saveChinese(data)

@app.route('/clendar', methods=['GET'])
def get_calendar():
    result = getCollection(collectionNames.calendar)
    data = {'greetings': result}
    return saveChinese(data)

@app.route('/classrooms', methods=['GET'])
def get_classrooms():
    result = getCollection(collectionNames.classrooms)
    data = {'greetings': result}
    return saveChinese(data)

@app.route('/clubs', methods=['GET'])
def get_clubs():
    result = getCollection(collectionNames.clubs)
    data = {'greetings': result}
    return saveChinese(data)

def saveChinese(data):
    response = make_response(json.dumps(data, ensure_ascii=False))
    response.headers['Content-Type'] = 'application/json; charset=utf-8'
    return response


if __name__ == "__main__":
    app.run(debug=True)
