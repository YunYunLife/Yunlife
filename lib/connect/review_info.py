from pymongo import MongoClient
from settings import MONGO_URI, DATABASE_NAME

# Connect to MongoDB
client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]
collection = db['articles']

def get_all_review_info():
    """
    從 MongoDB 獲取所有文章資訊
    """
    try:
        review_info_list = list(collection.find({}))
        if not review_info_list:
            return "沒有找到任何文章資訊。"
        return review_info_list
    except Exception as e:
        print(f"Error fetching review information: {e}")
        return "無法獲取文章資訊。請稍後再試。"

def format_review_info(review_info_list):
    """
    將文章（評論）資訊格式化為字符串
    """
    if isinstance(review_info_list, str):
        return review_info_list  # 如果是錯誤信息，直接返回

    formatted_info = "文章資訊如下：\n"
    for review in review_info_list:
        formatted_info += f"標題: {review.get('title', '無')}\n"
        formatted_info += f"日期: {review.get('date', '無')}\n"
        formatted_info += f"內容: {review.get('content', '無')}\n"
        formatted_info += f"標籤: {', '.join(review.get('tags', []))}\n\n"
    return formatted_info