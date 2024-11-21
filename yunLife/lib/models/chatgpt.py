import openai
from yunLife.lib.settings import OPENAI_API_KEY

openai.api_key = OPENAI_API_KEY
memory = []

def ask_gpt(prompt):
    messages = [{"role": "system", "content": "你是一個校園助理，請根據上下文回答問題。"}]
    messages.extend(memory)
    messages.append({"role": "user", "content": prompt})

    response = openai.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=messages,
        max_tokens=500
    )
    return response['choices'][0]['message']['content']

def update_memory(user_input, bot_response):
    global memory
    memory.append({"role": "user", "content": user_input})
    memory.append({"role": "assistant", "content": bot_response})
    if len(memory) > 6:
        memory = memory[-6:]
