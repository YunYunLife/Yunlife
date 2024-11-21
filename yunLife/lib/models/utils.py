from pymongo import MongoClient
from sentence_transformers import SentenceTransformer
from settings import MONGO_URI, DATABASE_NAME
import logging
from dateparser import parse

# 加載預訓練的 BERT 模型
model = SentenceTransformer('paraphrase-MiniLM-L6-v2')

def get_db_connection():
    """建立資料庫連線。"""
    client = MongoClient(MONGO_URI)
    return client[DATABASE_NAME]

def load_model():
    """加載預訓練的嵌入模型。"""
    return SentenceTransformer('paraphrase-MiniLM-L6-v2')

def parse_event_date(date_str):
    """解析日期字符串為標準日期格式。"""
    try:
        return parse(date_str)
    except Exception as e:
        logging.error(f"日期解析失敗：{e}")
        return None

def handle_error(error_message, error=None):
    """統一錯誤處理函數。"""
    if error:
        logging.error(f"{error_message} 詳細錯誤：{error}")
    return error_message
