from pymongo import MongoClient
from settings import MONGO_URI, DATABASE_NAME

# Connect to MongoDB
client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]
collection = db['clubs']

def get_all_club_info():
    """
    從 MongoDB 獲取所有社團資訊
    """
    try:
        club_info_list = list(collection.find({}))
        if not club_info_list:
            return "沒有找到任何社團資訊。"
        return club_info_list
    except Exception as e:
        print(f"Error fetching club information: {e}")
        return "無法獲取社團資訊。請稍後再試。"

def format_club_info(club_info_list):
    """
    將社團資訊格式化為字符串
    """
    if isinstance(club_info_list, str):
        return club_info_list  # 如果是錯誤信息，直接返回

    formatted_info = "社團資訊如下：\n"
    for club in club_info_list:
        formatted_info += f"社團名稱: {club.get('name', '無')}\n"
        formatted_info += f"社長: {club.get('president', '無')}\n"
        formatted_info += f"社團辦公室: {club.get('office', '無')}\n"
        formatted_info += f"集社時間: {club.get('meeting_time', '無')}\n"
        formatted_info += f"集社地點: {club.get('meeting_location', '無')}\n\n"
    return formatted_info


