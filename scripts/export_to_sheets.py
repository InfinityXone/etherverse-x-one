#!/usr/bin/env python3
"""
Export Etherverse memory and reflection data to Google Sheets.
Requires a service account JSON key from Google Cloud.
"""

import os, datetime, gspread
from google.oauth2.service_account import Credentials
from pathlib import Path

# Google Sheets setup
SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]
SERVICE_ACCOUNT_FILE = os.path.expanduser("~/.config/gcloud/google_service_key.json")

SPREADSHEET_ID = "PUT_YOUR_SHEET_ID_HERE"  # e.g., from the URL after /d/
SHEET_NAME = "Etherverse_Logs"

# Authorize client
creds = Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
client = gspread.authorize(creds)
sheet = client.open_by_key(SPREADSHEET_ID).worksheet(SHEET_NAME)

# Collect data
base = Path.home() / "etherverse"
docs = base / "docs"
memory = base / "memory"
logs = base / "logs"

rows = []
for file in docs.glob("*summary*.md"):
    content = file.read_text(encoding="utf-8")
    rows.append([datetime.date.today().isoformat(), "summary", file.name, len(content)])

for file in docs.glob("*dream*.md"):
    content = file.read_text(encoding="utf-8")
    rows.append([datetime.date.today().isoformat(), "dream", file.name, len(content)])

for file in logs.glob("*reflect.log"):
    size = os.path.getsize(file)
    rows.append([datetime.date.today().isoformat(), "reflection", file.name, size])

# Push to Google Sheet
sheet.append_rows(rows, value_input_option="USER_ENTERED")
print(f"[✓] Uploaded {len(rows)} entries to Google Sheets.")
