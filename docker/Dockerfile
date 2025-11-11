FROM python:3.9-slim

WORKDIR /app

COPY . .

RUN pip install --upgrade pip &&     pip install -r requirements.txt

CMD ["uvicorn", "core.intelligence_core:app", "--host", "0.0.0.0", "--port", "8000"]
