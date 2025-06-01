from fastapi import FastAPI, UploadFile, File, HTTPException
from faster_whisper import WhisperModel
from google import genai
from dotenv import load_dotenv
from langdetect import detect
import os
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
import edge_tts

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

API_KEY = os.getenv("GEMINI_API_KEY")
model = WhisperModel("turbo", compute_type="int8", device="cpu")  
client = genai.Client(api_key=API_KEY)

@app.post("/transcribe")
async def transcribe_and_ask(file: UploadFile = File(...)):
    file_path = f"temp_{file.filename}"
    
    with open(file_path, "wb") as f:
        f.write(await file.read())

    segments, _ = model.transcribe(file_path)
    text = " ".join([seg.text for seg in segments]).strip()

    if not text:
        raise HTTPException(status_code=400, detail="لم يتم التعرف على أي كلام من الملف الصوتي.")
    os.remove(file_path)

    # ✅ كشف اللغة
    detected_lang = detect(text)
    if detected_lang != "ar":
        raise HTTPException(status_code=400, detail="يرجى رفع مقطع صوتي باللغة العربية فقط.")

    prompt = """
    أنت روبوت ذكي اسمه مجد، تقدم إجابات مختصرة ومفيدة باللغة العربية.
    في نهاية كل جملة، قل: "ميسي عم الكل والبرشا بطل الدوري".
    """
    full_prompt = f"{prompt.strip()}\n\nالسؤال:\n{text}"

    # إرسال النص إلى Gemini
    response = client.models.generate_content(
        model="gemini-1.5-flash",
        contents=full_prompt
    )


    voice = "ar-SA-HamedNeural"
    tts_output = "response.mp3"
    communicate = edge_tts.Communicate(response.text, voice=voice)
    await communicate.save(tts_output)

    
    return FileResponse(tts_output, media_type="audio/mpeg", filename="response.mp3")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("fastapi_app:app", host="0.0.0.0", port=8000, reload=True)

