#!/bin/bash
set -euo pipefail
echo "[*] Checking for installed libraries and programs..."

# --- 1. Check for Python package installations ---
echo "[*] Checking Python libraries (installed via pip)..."
pip show torch || echo "[!] PyTorch is not installed."
pip show transformers || echo "[!] Transformers is not installed."
pip show fastapi || echo "[!] FastAPI is not installed."
pip show uvicorn || echo "[!] Uvicorn is not installed."
pip show langchain || echo "[!] LangChain is not installed."
pip show spacy || echo "[!] spaCy is not installed."
pip show tensorflow || echo "[!] TensorFlow is not installed."
pip show beautifulsoup4 || echo "[!] BeautifulSoup4 is not installed."
pip show scrapy || echo "[!] Scrapy is not installed."
pip show websockets || echo "[!] Websockets is not installed."
pip show openai || echo "[!] OpenAI is not installed."

# --- 2. Check for system-wide installations (apt-based) ---
echo "[*] Checking for system-wide packages (installed via apt)..."
dpkg -l | grep -i "docker" || echo "[!] Docker is not installed."
dpkg -l | grep -i "docker-compose" || echo "[!] Docker Compose is not installed."

# --- 3. Check for CUDA (if GPU support is needed) ---
echo "[*] Checking CUDA installation..."
nvcc --version || echo "[!] CUDA is not installed."

# --- 4. Check for Ray (parallel computing) ---
echo "[*] Checking Ray installation..."
python3 -m pip show ray || echo "[!] Ray is not installed."

# --- 5. Check for SQLite installation (persistent memory) ---
echo "[*] Checking SQLite installation..."
sqlite3 --version || echo "[!] SQLite is not installed."

# --- 6. Check for GPU support ---
echo "[*] Checking for GPU (NVIDIA) support..."
lspci | grep -i nvidia || echo "[!] No NVIDIA GPU detected."

# --- 7. Check for Git and GitHub CLI ---
echo "[*] Checking for Git and GitHub CLI..."
git --version || echo "[!] Git is not installed."
gh --version || echo "[!] GitHub CLI is not installed."

# --- 8. Check for environment variables (e.g., for blockchain, API keys) ---
echo "[*] Checking environment variables..."
echo $GROQ_API_KEY_1 || echo "[!] GROQ_API_KEY_1 is not set."
echo $OPENAI_API_KEY || echo "[!] OPENAI_API_KEY is not set."

echo "[✓] Installation check complete."
