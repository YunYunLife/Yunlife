import openai
import spacy
import dateparser
from settings import OPENAI_API_KEY, DATABASE_NAME, MONGO_URI
from pymongo import MongoClient
from sentence_transformers import SentenceTransformer, util
import torch
import dateparser

nlp = spacy.load("zh_core_web_sm")
client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]

openai.api_key = OPENAI_API_KEY
memory = []
MAX_MEMORY_LENGTH = 3

# 加載預訓練的 BERT 模型
model = SentenceTransformer('paraphrase-MiniLM-L6-v2')

def initialize_clubs_embeddings():
    # 從資料庫中提取所有社團的內容
    clubs = list(db.clubs.find({}, {'_id': 0, 'name': 1, 'president': 1, 'meeting_time': 1, 'meeting_place': 1}))

    # 將社團名稱轉換為嵌入向量
    club_corpus = [club['name'] for club in clubs]
    club_embeddings = model.encode(club_corpus, convert_to_tensor=True)

    return clubs, club_corpus, club_embeddings

def initialize_review_embeddings():
    # 從資料庫提取所有評價的內容
    reviews = list(db.articles.find({}, {'_id': 0, 'title': 1, 'date': 1, 'content': 1}))
    
    # 將評價內容轉換為嵌入向量
    review_corpus = [review['content'] for review in reviews]
    review_embeddings = model.encode(review_corpus, convert_to_tensor=True)
    
    return reviews, review_corpus, review_embeddings


def initialize_calendar_embeddings():
    # 從資料庫提取所有行事曆的內容
    calendar_events = list(db.calendar.find({}, {'_id': 0, '活動': 1, '活動日期': 1, '超連結': 1}))

    # 將活動內容轉換為嵌入向量
    calendar_corpus = [event['活動'] for event in calendar_events]
    calendar_embeddings = model.encode(calendar_corpus, convert_to_tensor=True)

    return calendar_events, calendar_corpus, calendar_embeddings

def initialize_classroom_embeddings():
    classrooms = list(db.classrooms.find({}, {"id":0, "空間代號": 1, "空間名稱": 1}))
    classroom_corpus = [f"{room['空間名稱']} {room['空間代號']}" for room in classrooms]

    classroom_embeddings = model.encode(classroom_corpus,convert_to_tensor=True)
    return classrooms, classroom_corpus, classroom_embeddings



# 在初始化時調用這個函數
reviews, reviews_corpus, review_embeddings = initialize_review_embeddings()
# 初始化時調用該函數來獲取社團嵌入向量
clubs, club_corpus, club_embeddings = initialize_clubs_embeddings()
# 初始化時調用該函數
calendar_events, calendar_corpus, calendar_embeddings = initialize_calendar_embeddings()

classrooms, classroom_corpus, classroom_embeddings = initialize_classroom_embeddings()


def parse_event_date(date_str):
    """
    使用 dateparser 解析日期字符串，支持不同的日期格式，如 '06/24' 或 '6月24日'
    """
    return dateparser.parse(date_str)

def get_calendars_by_exact_keyword(keywords, user_input):
    # 精確查找匹配的行事曆活動
    calendar_events = get_calendar_by_keywords(keywords)
    return generate_calendar_response(calendar_events, user_input) if calendar_events else None


def get_calendar_by_similarity(user_input):
    # 使用語意搜索來查找符合的行事曆活動
    query_embedding = model.encode(user_input, convert_to_tensor=True)
    cosine_scores = util.pytorch_cos_sim(query_embedding, calendar_embeddings)
    
    # 查找三個最相似的活動
    top_results = torch.topk(cosine_scores, k=3)

    relevant_events = []
    threshold = 0.85  # 設定相似度閾值

    # 提取符合閾值的行事曆活動
    for score, idx in zip(top_results.values.squeeze(), top_results.indices.squeeze()):
        if score.item() >= threshold:
            event = calendar_events[idx.item()]  # 從 calendar_events 中根據索引查找對應事件
            relevant_events.append({
                "活動": event['活動'],
                "活動日期": event['活動日期'],
                "超連結": event.get('超連結', '無超連結'),
                "相似度": score.item()
            })

    return relevant_events

def get_calendar_by_date(date_input, calendar_events):
    """
    根據使用者輸入的日期查找對應的活動
    """
    parsed_date = parse_event_date(date_input)
    
    if not parsed_date:
        return ["無法解析輸入的日期格式。請嘗試其他格式。"]

    relevant_events = []
    
    for event in calendar_events:
        event_date = parse_event_date(event['活動日期'])
        if event_date and event_date.date() == parsed_date.date():
            relevant_events.append({
                "活動": event['活動'],
                "活動日期": event['活動日期'],
                "超連結": event.get('超連結', '無超連結')
            })
    
    if relevant_events:
        return generate_calendar_response(relevant_events)
    else:
        return ["未找到對應日期的活動。"]

 
def get_review_by_exact_keyword(keywords, user_input):
    # 提取關鍵字並嘗試進行精確匹配

    reviews = get_reviews_by_keywords(keywords)
    return generate_review_response(reviews, user_input) if reviews else None
    

def get_review_by_similarity(user_input):
    """
    根據語意搜索查詢相似的課程評價
    """
    # 使用 BERT 模型進行相似度匹配
    query_embedding = model.encode(user_input, convert_to_tensor=True)
    cosine_scores = util.pytorch_cos_sim(query_embedding, review_embeddings)
    
    # 選擇相似度最高的結果
    top_results = torch.topk(cosine_scores, k=3)
    relevant_reviews = []
    
    # 設置相似度的閾值，過濾出與輸入文本相似度較高的評價
    for score, idx in zip(top_results[0], top_results[1].squeeze()):
        review_idx = idx.item()
    if score.item() >= 0.85:  # 相似度閾值  
         review = reviews[review_idx]
         relevant_reviews.append(f"課程名稱：{review['title']}，日期：{review['date']}，內容：{review['content']} (相似度: {score.item():.4f})")
    
    return generate_review_response(relevant_reviews) if relevant_reviews else "未找到相關的評價。"

def get_clubs_by_exact_keyword(keywords, user_input):
    """
    根據給定的關鍵字進行精確匹配社團資訊
    """
    clubs = get_clubs_by_keywords(keywords)
    return generate_club_response(clubs, user_input) if clubs else None

def get_clubs_by_similarity(user_input):
    """
    使用語意搜索來查找符合的社團名稱
    """
    query_embedding = model.encode(user_input, convert_to_tensor=True)
    cosine_scores = util.pytorch_cos_sim(query_embedding, club_embeddings)

    top_results = torch.topk(cosine_scores, k=3)  # 查找三個最相似的結果
    relevant_clubs = []

    threshold = 0.92  # 設定相似度閾值
    for score, idx in zip(top_results[0], top_results[1].squeeze()):
        club_idx = idx.items()
        if score.item() >= threshold:
            club = clubs[club_idx]
            relevant_clubs.append({
                "社團名稱": club['name'],
                "社長": club.get('president', '未知'),
                "集社時間": club.get('meeting_time', '未知'),
                "集社地點": club.get('meeting_place', '未知'),
                "相似度": score.item()
            })

    return generate_club_response(relevant_clubs) if relevant_clubs else "未找到相關社團資訊"

def get_classroom_by_exact_keyword(keywords):
    query = {
        "$or":[
            {"空間代號":{"$regex": f"{keywords}$", "$options": "i"}},
            {"空間名稱":{"$regex": f".*", "$options":"i"}}
        ]
    }
    result = db.classrooms.find_one(query, {"_id":0})
    return result if result else None

def get_classroom_by_similarity(user_input, classrooms, classroo_corpus, classroom_embeddings):
    query_embedding = model.encode(user_input, convert_to_tensor=True)
    cosine_scores = util.pytorch_cos_sin(query_embedding, classroom_embeddings)
    top_results = torch.topk(cosine_scores, k=3)
    relevent_classrooms = []
    threshold = 0.85
    for score, idx in zip(top_results.values.squeeze(), top_results.indices.squeeze()):
        if score.items() >= threshold:
            classroom = classrooms[idx.items()]
            relevent_classrooms.append(classroom)
    return relevent_classrooms        

    
def ask_gpt(prompt):
    """使用 ChatGPT 生成回應。"""
    messages = [{"role": "system", "content": "你是一個校園助理，請根據上下文回答問題。"}]
    messages.extend(memory)

      # 確保傳入的 prompt 是字符串
    if not isinstance(prompt, str):
        raise ValueError("prompt 應該是字符串類型，但收到的是其他類型")


    messages.append({"role": "user", "content": prompt})

    response = openai.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=messages,
        max_tokens=500
    )
    return response.choices[0].message.content.strip()

def update_memory(user_input, bot_response):
    """更新對話記憶。"""
    global memory
    memory.append({"role": "user", "content": user_input})
    memory.append({"role": "assistant", "content": bot_response})
    if len(memory) > MAX_MEMORY_LENGTH * 2:
        memory = memory[-MAX_MEMORY_LENGTH * 2:]

def extract_keywords(text):
    """使用 SpaCy 提取名詞和專有名詞作為關鍵字。"""
    doc = nlp(text)
    # 過濾停用詞並提取名詞、專有名詞、形容詞、副詞和動詞
    keywords = [
        token.text for token in doc 
        if token.pos_ in ["NOUN", "PROPN", "ADJ", "ADV", "VERB"] and token.text 
    ]
    return keywords


def get_reviews_by_keywords(keywords):
    # 使用 $regex 來匹配 title 或 content 中的關鍵字
    query = {
        "$or": [
            {"tags": {"$regex": keyword, "$options": "i"}} for keyword in keywords
        ] + [
            {"title": {"$regex": keyword, "$options": "i"}} for keyword in keywords
        ] + [
            {"content": {"$regex": keyword, "$options": "i"}} for keyword in keywords
        ]
    }
    
    # 查詢 articles 資料庫中的數據
    reviews = list(db.articles.find(query))
    return reviews if reviews else []

def get_clubs_by_keywords(keywords):
    """根據關鍵字查詢社團資訊。"""
    query = {"name": {"$regex": "|".join(keywords), "$options": "i"}}
    clubs = list(db.clubs.find(query, {"_id": 0}))
    return clubs if clubs else "未找到相關社團資訊"

def get_calendar_by_keywords(keywords):
    query = {
        "$or": [
            {"活動": {"$regex": "|".join(keywords), "$options": "i"}},
            ]+[
            {"活動日期": {"$regex": "|".join(keywords), "$options": "i"}}
        ]
    }
    events = list(db.calendar.find(query, {"_id": 0}))
    return events if events else "未在行事曆中找到資訊"


def generate_review_response(reviews, user_input):
    """用 GPT 來重新表述並過濾評價結果。"""
    if not reviews:
        return "未找到符合條件的課堂評價。"

    # 將篩選出的課程評價發送給 GPT
    reviews_text = "\n".join([
        f"課程名稱：{review.get('title', '未知')}，評價日期：{review.get('date', '未知')}，評價標籤：{', '.join(review.get('tags', []))}\n內容：{review.get('content', '無評價內容')}"
        for review in reviews
    ])

    prompt = f"使用者詢問的內容：{user_input}\n\n以下是一些課程的評價資訊：\n{reviews_text}\n請以雲林科技大學校園助理的身分，根據使用者的問題用口語化的語氣回答問題。"
    
    # 使用 GPT 生成過濾後的自然語言結果
    return ask_gpt(prompt)

def generate_club_response(clubs, user_input):
    """生成自然語言的社團資訊回應。"""
    clubs_text = "\n".join([
        f"社團名稱：{club['name']}，社長：{club.get('president', '未知')}，集社時間：{club.get('meeting_time', '未知')}，集社地點：{club.get('meeting_place', '未知')}"
        for club in clubs
    ])
    prompt = f"使用者詢問的內容：{user_input}\n\n以下是一些社團資訊{clubs_text}\n請以雲林科技大學校園助理的身分，請幫我用口語化的語氣回答使用者詢問內容。"

    return ask_gpt(prompt)


def generate_calendar_response(events, user_input):
    """生成自然語言的行事曆活動回應。"""
    events_text = "\n".join([
        f"活動名稱：{event['活動']}，日期：{event.get('活動日期', '未知')}，超連結：{event.get('超連結', '未知')}" 
        for event in events if isinstance(event, dict)
    ])
    
    prompt = f"使用者詢問的內容：{user_input}\n\n以下是一些行事曆活動：\n{events_text}\n請以雲林科技大學校園助理的身分，回答使用者詢問的內容。"
    # 確保 prompt 是字符串格式
    return ask_gpt(prompt)

def generate_classroom_response(result, user_input):
    classroom_info = (
        f"空間代號:{result['空間代號']}，空間名稱:{result['空間名稱']}，"
        f"教室位置:{result['教室位置']}，樓層:{result['樓層']}"
    )

    prompt = f"使用者詢問的內容：{user_input}\n\n以下是教室資訊：\n{classroom_info}\n請以雲林科技大學校園助理的身分，回答使用者詢問的內容。"
    return ask_gpt(prompt)


def process_user_input(user_input):
    """根據使用者輸入選擇查詢或新增行事曆。"""
    keywords = extract_keywords(user_input)

    possible_date = dateparser.parse(user_input)
    
    if possible_date:
        # 如果檢測到日期，根據日期查詢
        return get_calendar_by_date(user_input, calendar_events)

    if "社團" in user_input or "社" in user_input:
        # 先進行精確匹配查詢
        for keyword in keywords:
            exact_matches = get_clubs_by_exact_keyword(keyword, user_input)
            if exact_matches:
                return exact_matches
            return get_clubs_by_similarity(user_input)
        
        # 沒有精確匹配時，進行相似度搜索
        relevant_clubs = get_clubs_by_similarity(user_input, clubs, club_corpus, club_embeddings)
        return generate_club_response(relevant_clubs) if relevant_clubs else "未找到相關的社團資訊。"


        # 查詢評價，先進行精確匹配，無結果時再進行相似匹配
    elif "評價" in user_input or "課程" in user_input or "課" in user_input:
        # 精確匹配：先通過標題或標籤進行精確查詢
        exact_matches = get_review_by_exact_keyword(keywords, user_input)
        if exact_matches:
            return exact_matches
        
        return get_review_by_similarity(user_input)


    # 查詢行事曆或活動，先做精確查找，無結果時進行相似度查找
    elif "行事曆" in user_input or "活動" in user_input or "日期" in user_input or "時間" in user_input:
        # 首先進行精確匹配查找
        for keyword in keywords:
            exact_matches = get_calendars_by_exact_keyword(keywords, user_input)
            if exact_matches:
                return exact_matches
        
        # 如果沒有精確匹配，進行相似度查找
        relevant_events = get_calendar_by_similarity(user_input, calendar_corpus, calendar_embeddings)
        return generate_calendar_response(relevant_events) if relevant_events else "未找到相關的行事曆活動。"
    elif "位置" in user_input or "教室位置" in user_input or "在哪裡" in user_input:
        for keyword in keywords:
            exact_matches = get_classroom_by_exact_keyword(keywords, user_input)
            if exact_matches:
                return exact_matches
        relevant_classrooms = get+get_classroom_by_similarity(user_input, classroom_corpus, classroom_embeddings)
        return generate_classroom_response(relevant_classrooms)
    else:
        return ask_gpt(user_input)


