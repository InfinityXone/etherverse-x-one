#!/bin/bash

# --- Step 1: Move the credentials file to the correct location ---
echo "[🔧] Moving your credentials.json file to the correct directory..."
mkdir -p ~/etherverse/credentials
mv /mnt/data/etherverse-gcp-service-key.json ~/etherverse/credentials/credentials.json

# Verify the file was moved successfully
if [ -f "~/etherverse/credentials/credentials.json" ]; then
    echo "[✅] Credentials file successfully moved."
else
    echo "[❌] Failed to move credentials file."
    exit 1
fi

# --- Step 2: Set up Python environment and install dependencies ---
# Check if the virtual environment exists, if not, create it
if [ ! -d "~/etherverse/venv" ]; then
    echo "[🔧] Creating Python virtual environment..."
    python3 -m venv ~/etherverse/venv
fi

# Activate the virtual environment
echo "[🔧] Activating virtual environment..."
source ~/etherverse/venv/bin/activate

# Install necessary Python packages
echo "[🔧] Installing required Python packages (gspread, oauth2client)..."
pip install --upgrade pip
pip install gspread oauth2client

# --- Step 3: Run the Python Script to log data to Google Sheets ---
echo "[🔧] Running Google Sheets Logger script with new credentials..."
python3 ~/etherverse/google_sheets_logger.py

# --- Step 4: Confirm success ---
if [ $? -eq 0 ]; then
    echo "[✅] Data logged successfully into Google Sheets."
else
    echo "[❌] Something went wrong. Please check the logs."
    exit 1
fi

# End of script
