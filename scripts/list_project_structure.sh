#!/bin/bash
cd ~/etherverse || exit
echo "===== 🧠 Etherverse Project Structure ====="
find . -type d \( -name "venv" -o -name "__pycache__" -o -name ".git" \) -prune -false -o \
    -type f -print | grep -Ev "(__pycache__|\.pyc|\.log|\.tmp|\.swp)" | sort
echo "=========================================="
