from pymongo import MongoClient
from settings import MONGO_URI, DATABASE_NAME

client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]
collection = db['classrooms']

def get_all_classroom_info():
    """
    從 MongoDB 獲取所有教室資訊
    """
    try:
        classroom_info_list = list(collection.find({}))
        if not classroom_info_list:
            return "沒有找到任何教室資訊。"
        return classroom_info_list
    except Exception as e:
        print(f"Error fetching classroom information: {e}")
        return "無法獲取教室資訊。請稍後再試。"

def format_classroom_info(classroom_info_list):
    """
    將教室資訊格式化為字符串
    """
    if isinstance(classroom_info_list, str):
        return classroom_info_list

    formatted_info = "教室資訊如下：\n"
    for classroom in classroom_info_list:
        formatted_info += f"教室名稱: {classroom.get('name', '無')}\n"
        formatted_info += f"代碼: {classroom.get('code', '無')}\n"
        formatted_info += f"大樓: {classroom.get('building_name', '無')}\n"
        formatted_info += f"教室地址: {classroom.get('classroom_address', '無')}\n\n"
    return formatted_info
