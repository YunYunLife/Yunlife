from pymongo import MongoClient
from settings import MONGO_URI, DATABASE_NAME

client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]
collection = db['calendar']

def get_all_calendar_events():
    """
    獲取所有行事曆項目
    """
    try:
        calendar_events = list(collection.find({}))
        if not calendar_events:
            return "沒有找到任何行事曆項目。"
        return calendar_events
    except Exception as e:
        print(f"Error fetching calendar events: {e}")
        return "無法獲取行事曆項目。請稍後再試。"

def format_calendar_events(calendar_events):
    """
    將行事曆項目格式化為字符串
    """
    if isinstance(calendar_events, str):
        return calendar_events

    formatted_events = "行事曆項目如下：\n"
    for event in calendar_events:
        formatted_events += f"活動日期: {event.get('活動日期', '無')}\n"
        formatted_events += f"活動: {event.get('活動', '無')}\n"
        formatted_events += f"超連結: {event.get('超連結', '無')}\n\n"
    return formatted_events
