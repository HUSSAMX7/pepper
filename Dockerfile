FROM python:3.12.8

# تثبيت الأدوات الأساسية و OpenSSL
RUN apt-get update && \
    apt-get install -y curl openssl && \
    apt-get clean

# إنشاء مجلد العمل
WORKDIR /app

# نسخ ملفات المشروع
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# إضافة شهادة SSL ذاتية (للاختبار فقط)
# ملاحظة: يفضل استخدام شهادة رسمية من Let's Encrypt أو AWS ACM في الإنتاج
RUN openssl req -x509 -nodes -days 365 \
    -subj "/C=SA/ST=Riyadh/L=Riyadh/O=RMG/CN=localhost" \
    -newkey rsa:2048 -keyout key.pem -out cert.pem

# تعيين البورت
EXPOSE 443

# تشغيل Uvicorn باستخدام HTTPS
CMD ["uvicorn", "fastapi_app:app", "--host", "0.0.0.0", "--port", "443", "--ssl-keyfile=key.pem", "--ssl-certfile=cert.pem"]


