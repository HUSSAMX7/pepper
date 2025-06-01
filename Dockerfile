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

# توليد شهادة SSL (موقعة ذاتيًا)
RUN openssl req -x509 -nodes -days 365 \
    -subj "/C=SA/ST=Riyadh/L=Riyadh/O=RMG/CN=localhost" \
    -newkey rsa:2048 -keyout key.pem -out cert.pem

# تحديد المنفذ (HTTPS)
EXPOSE 443

# تشغيل التطبيق باستخدام Uvicorn عبر HTTPS
CMD ["uvicorn", "fastapi_app:app", "--host", "0.0.0.0", "--port", "443", "--ssl-keyfile", "key.pem", "--ssl-certfile", "cert.pem"]
