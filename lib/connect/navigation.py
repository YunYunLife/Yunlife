import googlemaps
from pymongo import MongoClient
from settings import GOOGLE_MAPS_API_KEY, MONGO_URI, DATABASE_NAME

gmaps = googlemaps.Client(key=GOOGLE_MAPS_API_KEY)
# Connect to MongoDB
client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]
collection = db['classrooms']

def get_navigation_url(classroom_info):
    """
    根據教室信息生成導航 URL
    """
    if 'latitude' in classroom_info and 'longitude' in classroom_info:
        lat = classroom_info['latitude']
        lng = classroom_info['longitude']
        return f"https://www.google.com/maps/dir/?api=1&destination={lat},{lng}"
    elif 'building_address' in classroom_info:
        location = classroom_info['building_address']
        geocode_result = gmaps.geocode(location)
        if geocode_result:
            lat = geocode_result[0]['geometry']['location']['lat']
            lng = geocode_result[0]['geometry']['location']['lng']
            return f"https://www.google.com/maps/dir/?api=1&destination={lat},{lng}"
    return "未找到導航信息"
