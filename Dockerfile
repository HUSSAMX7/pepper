FROM python:3.12.8

# تثبيت الأدوات الأساسية و OpenSSL
RUN apt-get update && \
    apt-get install -y curl openssl && \
    apt-get clean

# تحديد مجلد العمل
WORKDIR /app

# نسخ متطلبات المشروع وتثبيتها
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# نسخ باقي ملفات المشروع
COPY . .

env GEMINI_API_KEY = ${GEMINI_API_KEY}
EXPOSE 8000

# تشغيل التطبيق باستخدام Uvicorn عبر HTTPS
CMD ["uvicorn", "fastapi_app:app", "--host", "0.0.0.0", "--port", "8000"]
