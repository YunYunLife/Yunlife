from sentence_transformers import SentenceTransformer, util
import torch

class ClassroomHandler:
    def __init__(self, db):
        self.db = db
        self.model = SentenceTransformer('paraphrase-MiniLM-L6-v2')
        self.classrooms, self.classroom_corpus, self.classroom_embeddings = self.initialize_classroom_embeddings()

    def initialize_classroom_embeddings(self):
        classrooms = list(self.db.classrooms.find({}, {'_id': 0, '空間代號': 1, '空間名稱': 1, '教室位置': 1, '樓層': 1}))
        classroom_corpus = [room['空間名稱'] for room in classrooms]
        classroom_embeddings = self.model.encode(classroom_corpus, convert_to_tensor=True)
        return classrooms, classroom_corpus, classroom_embeddings

    def get_classroom_by_similarity(self, user_input):
        query_embedding = self.model.encode(user_input, convert_to_tensor=True)
        cosine_scores = util.pytorch_cos_sim(query_embedding, self.classroom_embeddings)

        top_results = torch.topk(cosine_scores, k=3)
        relevant_classrooms = []

        threshold = 0.92
        for score, idx in zip(top_results[0], top_results[1].squeeze()):
            if score.item() >= threshold:
                classroom = self.classrooms[idx.item()]
                relevant_classrooms.append({
                    "空間代號": classroom.get('空間代號', '未知'),
                    "空間名稱": classroom.get('空間名稱', '未知'),
                    "教室位置": classroom.get('教室位置', '未知'),
                    "樓層": classroom.get('樓層', '未知'),
                    "相似度": score.item()
                })

        return relevant_classrooms
