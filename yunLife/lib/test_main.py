import requests
import json

BASE_URL = "http://127.0.0.1:5000"

def test_home():
    response = requests.get(BASE_URL + "/")
    print("Test Home Response:")
    print(response.text)

def test_add_event():
    payload = {
        "prompt": "新增事件 2024-11-20 測試會議",
        "username": "B11023001"
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post(BASE_URL + "/ask", json=payload, headers=headers)
    print("Test Add Event Response:")
    print(response.json())

def test_view_calendar():
    payload = {
        "prompt": "查看行事曆",
        "username": "B11023001"
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post(BASE_URL + "/ask", json=payload, headers=headers)
    print("Test View Calendar Response:")
    print(response.json())

def test_club_query():
    payload = {
        "prompt": "查詢籃球社",
        "username": "B11023001"
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post(BASE_URL + "/ask", json=payload, headers=headers)
    print("Test Club Query Response:")
    print(response.json())

if __name__ == "__main__":
    print("Starting API Tests...")
    test_home()
    print("\n------------------------\n")
    test_add_event()
    print("\n------------------------\n")
    test_view_calendar()
    print("\n------------------------\n")
    test_club_query()
