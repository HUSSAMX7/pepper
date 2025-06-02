FROM python:3.12.8

RUN apt-get update && \
    apt-get install -y curl openssl && \
    apt-get clean

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# تعريف المتغير قبل استخدامه
ARG GEMINI_API_KEY
ENV GEMINI_API_KEY=$GEMINI_API_KEY

EXPOSE 8000

CMD ["uvicorn", "fastapi_app:app", "--host", "0.0.0.0", "--port", "443"]
