FROM python:3.11-slim
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1
WORKDIR /app
COPY api/app/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
RUN mkdir -p /app/api/app/routes && touch /app/api/__init__.py /app/api/app/__init__.py /app/api/app/routes/__init__.py
COPY api /app/api
ENV PORT=8080 PYTHONPATH=/app
CMD ["uvicorn","api.app.main:app","--host","0.0.0.0","--port","8080"]
