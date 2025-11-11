#!/bin/bash
set -euo pipefail
echo "[*] Checking essential software and dependencies across the entire system..."

# --- 1. Check for Python and key packages (Globally) ---
echo "[*] Checking Python installation..."
python3 --version || echo "[!] Python3 is not installed."

# Check for key packages globally
echo "[*] Checking FastAPI, Uvicorn, TensorFlow, PyTorch, etc..."
pip show fastapi || echo "[!] FastAPI not installed."
pip show uvicorn || echo "[!] Uvicorn not installed."
pip show torch || echo "[!] PyTorch not installed."
pip show transformers || echo "[!] Transformers not installed."
pip show langchain || echo "[!] LangChain not installed."
pip show spacy || echo "[!] spaCy not installed."
pip show tensorflow || echo "[!] TensorFlow not installed."
pip show cuda || echo "[!] CUDA not installed."

# --- 2. Check for Docker and Docker Compose (Globally) ---
echo "[*] Checking Docker and Docker Compose installation..."
docker --version || echo "[!] Docker is not installed."
docker-compose --version || echo "[!] Docker Compose is not installed."

# --- 3. Check for CUDA (if GPU support is needed) ---
echo "[*] Checking CUDA installation..."
nvcc --version || echo "[!] CUDA is not installed."

# --- 4. Check for Ray and other parallel computing tools ---
echo "[*] Checking Ray installation..."
python3 -m pip show ray || echo "[!] Ray not installed."

# --- 5. Check for Web Scraping Tools (Globally) ---
echo "[*] Checking for web scraping tools..."
pip show beautifulsoup4 || echo "[!] BeautifulSoup4 not installed."
pip show scrapy || echo "[!] Scrapy not installed."

# --- 6. Check for WebSocket/HTTP support for the agent gateway (Globally) ---
echo "[*] Checking WebSocket and HTTP support..."
pip show websockets || echo "[!] Websockets not installed."
pip show requests || echo "[!] Requests library not installed."

# --- 7. Check for AI Model Interfaces (Groq, OpenAI, etc.) ---
echo "[*] Checking AI model interfaces (Groq, OpenAI)..."
pip show openai || echo "[!] OpenAI library not installed."
echo $GROQ_API_KEY_1 || echo "[!] GROQ API key is not set."
echo $OPENAI_API_KEY || echo "[!] OpenAI API key is not set."

# --- 8. Check for Blockchain-related dependencies ---
echo "[*] Checking Blockchain-related dependencies..."
pip show web3 || echo "[!] Web3 not installed."
pip show eth-account || echo "[!] Ethereum account library not installed."

# --- 9. Check for Git and GitHub CLI ---
echo "[*] Checking for Git and GitHub CLI..."
git --version || echo "[!] Git is not installed."
gh --version || echo "[!] GitHub CLI is not installed."

# --- 10. Check if environment variables are set (for persistent memory, etc.) ---
echo "[*] Checking required environment variables..."
echo $IPC_SOCKET_PATH || echo "[!] IPC_SOCKET_PATH is not set."
echo $SUPABASE_URL || echo "[!] SUPABASE_URL is not set."
echo $VERCEL_URL || echo "[!] VERCEL_URL is not set."
echo $GITHUB_TOKEN || echo "[!] GITHUB_TOKEN is not set."
echo $SUPABASE_SERVICE_ROLE_KEY || echo "[!] SUPABASE_SERVICE_ROLE_KEY is not set."

# --- 11. Check if the Ethereum node connection is set up (CoreChain) ---
echo "[*] Checking Ethereum node and blockchain setup..."
echo $CORECHAIN_NODE_URL || echo "[!] CORECHAIN_NODE_URL is not set."
echo $INFURA_RPC_API_KEY || echo "[!] INFURA_RPC_API_KEY is not set."

echo "[✓] Full system software check complete."
