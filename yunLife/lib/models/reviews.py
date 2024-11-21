from sentence_transformers import SentenceTransformer, util
import torch

class ReviewHandler:
    def __init__(self, db):
        self.db = db
        self.model = SentenceTransformer('paraphrase-MiniLM-L6-v2')
        self.reviews, self.review_corpus, self.review_embeddings = self.initialize_review_embeddings()

    def initialize_review_embeddings(self):
        reviews = list(self.db.articles.find({}, {'_id': 0, 'title': 1, 'date': 1, 'content': 1}))
        review_corpus = [review['content'] for review in reviews]
        review_embeddings = self.model.encode(review_corpus, convert_to_tensor=True)
        return reviews, review_corpus, review_embeddings
    
    def get_reviews_by_exact_keyword(self, keywords):

        # 定義查詢條件，使用 $regex 進行模糊匹配
        query = {
            "$or": [
                {"tags": {"$regex": "|".join(keywords), "$options": "i"}},
                {"title": {"$regex": "|".join(keywords), "$options": "i"}},
                {"content": {"$regex": "|".join(keywords), "$options": "i"}},
            ]
        }
    # 執行查詢，返回匹配結果
        reviews = list(self.db.articles.find(query))
        return reviews if reviews else []

    def get_reviews_by_similarity(self, user_input):
        query_embedding = self.model.encode(user_input, convert_to_tensor=True)
        cosine_scores = util.pytorch_cos_sim(query_embedding, self.review_embeddings)

        top_results = torch.topk(cosine_scores, k=5)
        relevant_reviews = []

        threshold = 0.85
        for score, idx in zip(top_results[0], top_results[1].squeeze()):
            if score.item() >= threshold:
                review = self.reviews[idx.item()]
                relevant_reviews.append({
                    "課程名稱": review.get('title', '未知'),
                    "日期": review.get('date', '未知'),
                    "內容": review.get('content', '無評價內容'),
                    "相似度": score.item()
                })

        return relevant_reviews
    
    def generate_review_response(self, reviews, user_input):
        """
        生成課程評價的自然語言回應。

        :param reviews: 篩選後的課程評價列表
        :param user_input: 使用者輸入
        :return: 經 ChatGPT 處理的自然語言回應
        """
        if not reviews:
            return "未找到符合條件的課程評價。"

        reviews_text = "\n".join([
            f"課程名稱：{review.get('title', '未知')}，評價日期：{review.get('date', '未知')}，\n內容：{review.get('content', '無評價內容')}"
            for review in reviews
        ])
        prompt = f"以下是雲林科技大學的課程評價資訊：\n{reviews_text}\n使用者詢問的問題：{user_input}\n\n" \
                 "請以雲林科技大學校園助理的身分，根據以上課程評價資訊回答使用者詢問的問題。"

        print(f"Prompt sent to ChatGPT:\n{prompt}")
        return self.ask_gpt(prompt)
    
    def process_review_query(self, user_input, keywords):
        """
        處理課程評價的查詢，根據輸入進行精確匹配或相似度搜索。

        :param user_input: 使用者的查詢文本
        :param keywords: 從使用者輸入中提取的關鍵字
        :return: ChatGPT 生成的回應
        """
        exact_matches = self.get_reviews_by_exact_keyword(keywords)
        if exact_matches:
            return self.generate_review_response(exact_matches, user_input)

        similar_reviews = self.get_reviews_by_similarity(user_input)
        return self.generate_review_response(similar_reviews, user_input)
    
