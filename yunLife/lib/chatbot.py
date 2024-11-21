from db import db  
from models.clubs import ClubHandler
from models.reviews import ReviewHandler
from models.calendar import CalendarHandler
from models.classrooms import ClassroomHandler
from models.chatgpt import ask_gpt

# 初始化模組
club_handler = ClubHandler(db)
review_handler = ReviewHandler(db)
calendar_handler = CalendarHandler(db)
classroom_handler = ClassroomHandler(db)

# 全局記憶
memory = []
MAX_MEMORY_LENGTH = 3

def update_memory(user_input, bot_response):
    """
    更新對話記憶，用於 ChatGPT 的上下文。
    """
    global memory
    memory.append({"role": "user", "content": user_input})
    memory.append({"role": "assistant", "content": bot_response})
    if len(memory) > MAX_MEMORY_LENGTH * 2:
        memory = memory[-MAX_MEMORY_LENGTH * 2:]


def process_user_input(user_input, username=None):
    """
    處理使用者的輸入，並根據不同模組執行相應功能。
    """
    try:
        user_input = user_input.strip().lower()

        # 處理社團相關查詢
        if "社團" in user_input or "社" in user_input:
            return club_handler.process_club_query(user_input)

        # 處理課堂評價相關查詢
        elif "評價" in user_input or "課程" in user_input or "課" in user_input:
            return review_handler.process_review_query(user_input)

        # 處理行事曆相關查詢
        elif "行事曆" in user_input or "活動" in user_input or "日期" in user_input:
            if username:
                if "新增事件" in user_input:
                    split_input = user_input.split(maxsplit=2)
                    if len(split_input) < 3:
                        return "新增行事曆失敗，請提供完整的日期和事件內容。"
                    date_str = split_input[1]
                    event = split_input[2]
                    return calendar_handler.add_event_to_calendar(username, date_str, event)
                else:
                    return calendar_handler.get_personal_calendar(username)
            else:
                return "未登入，無法使用個人行事曆功能。"

        # 處理教室位置查詢
        elif "教室" in user_input or "位置" in user_input:
            return classroom_handler.process_classroom_query(user_input)

        # 其他輸入使用 ChatGPT 處理
        else:
            response = ask_gpt(user_input, memory)
            update_memory(user_input, response)
            return response

    except Exception as e:
        return f"處理輸入時發生錯誤：{str(e)}"