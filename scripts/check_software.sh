#!/bin/bash
set -euo pipefail
echo "[*] Checking essential software and dependencies in ~/etherverse..."

# --- 1. Check for Python and key packages ---
echo "[*] Checking Python and key packages..."
python3 --version
pip show fastapi
pip show uvicorn
pip show torch
pip show transformers
pip show langchain
pip show spacy
pip show tensorflow
pip show cuda

# --- 2. Check for Docker and Docker Compose ---
echo "[*] Checking Docker and Docker Compose..."
docker --version
docker-compose --version

# --- 3. Check for CUDA (if GPU support is needed) ---
echo "[*] Checking CUDA installation..."
nvcc --version

# --- 4. Check for Ray and other parallel computing tools ---
echo "[*] Checking Ray installation (for distributed computing)..."
python3 -m pip show ray

# --- 5. Check for Web Scraping Tools ---
echo "[*] Checking for web scraping tools..."
pip show beautifulsoup4
pip show scrapy

# --- 6. Check for WebSocket/HTTP support for the agent gateway ---
echo "[*] Checking WebSocket/HTTP support..."
pip show websockets
pip show requests

# --- 7. Check for AI Model Interfaces (Groq, OpenAI, etc.) ---
echo "[*] Checking Groq, OpenAI API setup..."
pip show openai
echo $GROQ_API_KEY_1
echo $OPENAI_API_KEY

# --- 8. Check for Blockchain-related dependencies ---
echo "[*] Checking for Blockchain-related dependencies..."
pip show web3
pip show eth-account

# --- 9. Check for Git and GitHub CLI ---
echo "[*] Checking for Git and GitHub CLI..."
git --version
gh --version

# --- 10. Check if environment variables are set (for persistent memory, etc.) ---
echo "[*] Checking for required environment variables..."
echo $IPC_SOCKET_PATH
echo $SUPABASE_URL
echo $VERCEL_URL
echo $GITHUB_TOKEN
echo $SUPABASE_SERVICE_ROLE_KEY

# --- 11. Check if the Ethereum node connection is set up (CoreChain) ---
echo "[*] Checking Ethereum node and blockchain setup..."
echo $CORECHAIN_NODE_URL
echo $INFURA_RPC_API_KEY

echo "[✓] Software check complete in ~/etherverse."
