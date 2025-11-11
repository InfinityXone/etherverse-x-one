#!/bin/bash
# Set up the Docker container
docker-compose up --build -d

# Launch the backend server
uvicorn core.intelligence_core:app --host 0.0.0.0 --port 8000 --reload

# Launch the frontend (assistant UI)
python3 ~/etherverse/scripts/assistant_ui.py
