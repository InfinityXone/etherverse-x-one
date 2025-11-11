#!/usr/bin/env python3
import gspread
from google.oauth2.service_account import Credentials

SHEET_ID = "1f2XMHWdZYyl30W2QlpTnPGLphJZVVc82JFvyNMFScCk"
KEY_PATH = "/home/etherverse/.config/gcloud/google_service_key.json"

print("===== 🔗 Testing Google Sheets Connection =====")
try:
    creds = Credentials.from_service_account_file(
        KEY_PATH,
        scopes=[
            "https://www.googleapis.com/auth/spreadsheets",
            "https://www.googleapis.com/auth/drive",
        ],
    )
    client = gspread.authorize(creds)
    sheet = client.open_by_key(SHEET_ID)
    print(f"[✓] Connected successfully → {sheet.title}")
    print("[+] Available tabs:")
    for ws in sheet.worksheets():
        print(f"   - {ws.title}")
    print("===== ✅ Connection Verified =====")
except Exception as e:
    print("❌ Connection failed:")
    print(e)
