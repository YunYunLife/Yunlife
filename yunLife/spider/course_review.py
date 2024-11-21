from selenium import webdriver
# 連接到 MongoDBfrom selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from pymongo import MongoClient
import time

# 連接到 MongoDB
client = MongoClient("mongodb://localhost:27017/")
db = client['yuntech_db']
collection = db['articles']

# 設定 WebDriver
driver = webdriver.Chrome()

# 打開特定 URL
driver.get("https://www.1111opt.com.tw/search-result/JTdCJTIydHlwZSUyMiUzQTAlMkMlMjJvcmRlciUyMiUzQSUyMi1tb2RpZnlfdGltZSUyMiUyQyUyMmtleXdvcmQlMjIlM0ElMjIlRTklOUIlQjIlRTclQTclOTElRTUlQTQlQTclMjIlMkMlMjJjb2xsZWdlX2lkJTIyJTNBMTA5MzUyNTYlMkMlMjJjb2xsZWdlJTIyJTNBJTIyJUU1JTlDJThCJUU3JUFCJThCJUU5JTlCJUIyJUU2JTlFJTk3JUU3JUE3JTkxJUU2JThBJTgwJUU1JUE0JUE3JUU1JUFEJUI4JTIyJTJDJTIycGFnZSUyMiUzQTElN0Q")

# 抓取頁面文章的函數
def scrape_articles():
    articles = WebDriverWait(driver, 10).until(
        EC.presence_of_all_elements_located((By.CSS_SELECTOR, "div.w\\:full.p\\:16.d\\:block"))
    )

    for article in articles:
        try:
            title = article.find_element(By.CSS_SELECTOR, "div.max-w\\:580 span.lines\\:2.color\\:\\#333333.font-weight\\:700.f\\:18.lh\\:26px").text
            date = article.find_element(By.CSS_SELECTOR, "span.lines\\:1.font-weight\\:400.f\\:14px.line-height\\:20px.color\\:\\#A9A9A9").text
            content = article.find_element(By.CSS_SELECTOR, "span.lines\\:2.color\\:\\#6F737D.f\\:14.font-weight\\:400.lh\\:20px").text
            tags = article.find_elements(By.CSS_SELECTOR, "ul.w\\:full li.d\\:inline-block.m\\:4\\.5 span")
            tags_text = [tag.text for tag in tags]

            # 構建資料字典
            article_data = {
                "title": title,
                "date": date,
                "content": content,
                "tags": tags_text
            }

            # 檢查資料是否已存在，避免重複插入
            if collection.find_one({"title": title}):
                print(f"文章已存在，跳過: {title}")
            else:
                collection.insert_one(article_data)
                print(f"已儲存文章: {title}")

        except Exception as e:
            print(f"抓取單篇文章時出錯: {e}")
            continue

# 循環抓取 90 頁
try:
    for page in range(1, 91):
        print(f"抓取第 {page} 頁...")
        scrape_articles()

        # 點擊下一頁按鈕
        if page < 90:  # 避免超出範圍
            try:
                next_page_button = WebDriverWait(driver, 10).until(
                 EC.element_to_be_clickable((By.LINK_TEXT, str(page + 1)))
                )

                # 滚动到下一页按钮
                driver.execute_script("arguments[0].scrollIntoView(true);", next_page_button)
                time.sleep(1)  # 确保滚动完成后稍作等待

                next_page_button.click()

                # 等待頁面加載完成
            
                time.sleep(3)

            except Exception as e:
                print(f"第 {page} 頁無法點擊下一頁: {e}")
                continue
            


except Exception as e:
    print(f"抓取過程中出錯: {e}")

finally:
    # 關閉瀏覽器和 MongoDB 連接
    driver.quit()
    client.close()