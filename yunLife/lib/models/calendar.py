from sentence_transformers import SentenceTransformer, util
import dateparser
import torch

class CalendarHandler:
    def __init__(self, db):
        self.db = db
        self.model = SentenceTransformer('paraphrase-MiniLM-L6-v2')
        self.calendar_events, self.calendar_corpus, self.calendar_embeddings = self.initialize_calendar_embeddings()

    def initialize_calendar_embeddings(self):
        calendar_events = list(self.db.calendar.find({}, {'_id': 0, '活動': 1, '活動日期': 1}))
        calendar_corpus = [event['活動'] for event in calendar_events]
        calendar_embeddings = self.model.encode(calendar_corpus, convert_to_tensor=True)
        return calendar_events, calendar_corpus, calendar_embeddings

    def parse_event_date(self, date_str):
        return dateparser.parse(date_str)

    def add_event_to_calendar(self, username, date, event):
        try:
            self.db.user_calendar.insert_one({
                "學號": username,
                "日期": date,
                "事件": event
            })
            return "事件新增成功！"
        except Exception as e:
            return f"新增事件時發生錯誤：{str(e)}"

    def get_personal_calendar(self, username):
        events = list(self.db.user_calendar.find({"學號": username}, {"_id": 0}))
        if not events:
            return "您的行事曆是空的。"

        return "\n".join([f"日期：{event['日期']}，事件：{event['事件']}" for event in events])
