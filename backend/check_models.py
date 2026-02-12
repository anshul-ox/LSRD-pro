import google.generativeai as genai
import os

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyAFAFdGR842HI_p0O4NjoKTEr_BE1btwcI")
genai.configure(api_key=GEMINI_API_KEY)

with open("models_out.txt", "w", encoding="utf-8") as f:
    try:
        for m in genai.list_models():
            if 'generateContent' in m.supported_generation_methods:
                print(m.name)
                f.write(m.name + "\n")
    except Exception as e:
        print(f"Error: {e}")
        f.write(f"Error: {e}\n")
