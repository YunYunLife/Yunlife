from sentence_transformers import SentenceTransformer, util
import torch

class ClubHandler:
    def __init__(self, db):
        self.db = db
        self.model = SentenceTransformer('paraphrase-MiniLM-L6-v2')
        self.clubs, self.club_corpus, self.club_embeddings = self.initialize_clubs_embeddings()

    def initialize_clubs_embeddings(self):
        clubs = list(self.db.clubs.find({}, {'_id': 0, 'name': 1, 'president': 1, 'meeting_time': 1, 'meeting_place': 1}))
        club_corpus = [club['name'] for club in clubs]
        club_embeddings = self.model.encode(club_corpus, convert_to_tensor=True)
        return clubs, club_corpus, club_embeddings

    def get_clubs_by_similarity(self, user_input):
        query_embedding = self.model.encode(user_input, convert_to_tensor=True)
        cosine_scores = util.pytorch_cos_sim(query_embedding, self.club_embeddings)

        top_results = torch.topk(cosine_scores, k=5)
        relevant_clubs = []

        threshold = 0.92
        for score, idx in zip(top_results[0], top_results[1].squeeze()):
            if score.item() >= threshold:
                club = self.clubs[idx.item()]
                relevant_clubs.append({
                    "社團名稱": club['name'],
                    "社長": club.get('president', '未知'),
                    "集社時間": club.get('meeting_time', '未知'),
                    "集社地點": club.get('meeting_place', '未知'),
                    "相似度": score.item()
                })

        return relevant_clubs

    def get_clubs_by_keywords(self, keywords):
        query = {"name": {"$regex": "|".join(keywords), "$options": "i"}}
        clubs = list(self.db.clubs.find(query, {"_id": 0}))
        return clubs
