import openai
# Correct the import path to 'settings' instead of 'setting'
from settings import OPENAI_API_KEY
from mongoConnect import classrooms  # Import classroom collection
from club_info import get_all_club_info, format_club_info
from review_info import get_all_review_info, format_review_info
from classroom_info import get_all_classroom_info, format_classroom_info
from calendar_info import get_all_calendar_events, format_calendar_events
from navigation import get_navigation_url

# Initialize OpenAI client
openai.api_key = OPENAI_API_KEY

# Memory for the bot to track recent interactions
memory = []
MAX_MEMORY_LENGTH = 3

# ChatGPT and Input Handlers
def ask_gpt_with_memory(prompt, context=''):
    global memory
    messages = [{"role": "system", "content": "你是一個校園助理，以下是所有相關資訊的數據。根據這些數據回答問題。"}]
    messages.extend(memory)
    if context:
        messages.append({"role": "system", "content": context})
    messages.append({"role": "user", "content": prompt})

    response = openai.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=messages,
        max_tokens=500
    )
    return response.choices[0].message.content.strip()

def update_memory(user_input, bot_response):
    global memory
    memory.append({"role": "user", "content": user_input})
    memory.append({"role": "assistant", "content": bot_response})

    if len(memory) > MAX_MEMORY_LENGTH * 2:
        memory = memory[-MAX_MEMORY_LENGTH * 2:]

def recommend_classes():
    all_reviews = get_all_review_info()
    recommended_classes = []

    if all_reviews and not isinstance(all_reviews, str):
        for review in all_reviews:
            tags = review.get('tags', [])
            if '# 分數高' in tags or '# 學的很淺' in tags:
                recommended_classes.append(review)

    return format_review_info(recommended_classes) if recommended_classes else "目前沒有特別推薦的課程。"

def handle_club_query(user_input):
    all_club_info = get_all_club_info()
    club_name = user_input.replace("社團", "").strip()
    relevant_clubs = [club for club in all_club_info if club_name in club['name'].lower()]

    if relevant_clubs:
        return format_club_info(relevant_clubs)
    else:
        return f"未找到 {club_name} 的相關社團資訊。"

def handle_calendar_query(user_input):
    all_calendar_events = get_all_calendar_events()
    event_name = user_input.replace("行事曆", "").strip()
    relevant_events = [event for event in all_calendar_events if event_name in event['title'].lower()]

    if relevant_events:
        return format_calendar_events(relevant_events)
    else:
        return f"未找到 {event_name} 的相關行事曆活動。"

def handle_classroom_query(user_input):
    all_classroom_info = get_all_classroom_info()
    classroom_name = user_input.replace("教室", "").strip()
    relevant_classrooms = [classroom for classroom in all_classroom_info if classroom_name in classroom['name'].lower()]

    if relevant_classrooms:
        return format_classroom_info(relevant_classrooms)
    else:
        return f"未找到 {classroom_name} 的相關教室資訊。"

def handle_review_query(user_input):
    course_name = user_input.replace("課堂評價", "").strip()
    all_reviews = get_all_review_info()

    relevant_reviews = [review for review in all_reviews if course_name in review['title'].lower()]
    return format_review_info(relevant_reviews) if relevant_reviews else f"未找到 {course_name} 的相關課堂評價。"

def handle_navigation_query(user_input):
    classroom_name_or_code = user_input.split()[-1]
    # Use classroom_collection from the MongoDB client
    classroom_info = classrooms.find_one({'$or': [{'name': classroom_name_or_code}, {'code': classroom_name_or_code}]})

    if classroom_info:
        return f'導航至教室的連結: {get_navigation_url(classroom_info)}'
    else:
        return '未找到該教室的信息。'

def process_user_input(user_input):
    if "社團" in user_input:
        return handle_club_query(user_input)
    elif "行事曆" in user_input:
        return handle_calendar_query(user_input)
    elif "教室" in user_input:
        return handle_classroom_query(user_input)
    elif "課堂評價" in user_input:
        return handle_review_query(user_input)
    elif "推薦" in user_input:
        return recommend_classes()
    elif "導航" in user_input:
        return handle_navigation_query(user_input)
    else:
        return ask_gpt_with_memory(user_input)
