import gspread
from oauth2client.service_account import ServiceAccountCredentials
from datetime import datetime

# Function to authenticate Google Sheets
def authenticate_gsheets():
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    creds = ServiceAccountCredentials.from_json_keyfile_name('credentials.json', scope)  # Path to your credentials
    client = gspread.authorize(creds)
    return client

# Function to create a new Google Sheet
def create_new_sheet(client):
    spreadsheet = client.create('Master Memory File')  # Create a new spreadsheet
    worksheet = spreadsheet.sheet1
    worksheet.update_title('Agent Memory Logs')  # Rename the default sheet to 'Agent Memory Logs'
    
    # Set headers
    worksheet.append_row(['Agent Name', 'Date', 'Reflection', 'Action Taken', 'Memory Type', 'Status', 'Log Entry'])
    
    print(f"Google Sheet '{spreadsheet.title}' created successfully.")
    return worksheet

# Function to log memory reflection into Google Sheets
def log_to_google_sheets(agent_name, reflection, action_taken, memory_type, status, log_entry, worksheet):
    date_now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    worksheet.append_row([agent_name, date_now, reflection, action_taken, memory_type, status, log_entry])
    print(f"Logged reflection for {agent_name} at {date_now}.")

# Example of adding multiple reflections
def log_multiple_reflections():
    # Authenticate and connect to Google Sheets
    client = authenticate_gsheets()
    worksheet = create_new_sheet(client)

    # Example entries (replace these with your actual logs or data extraction logic)
    reflections = [
        ("Agent 1", "Reflection 1", "Action 1", "Memory Type A", "Active", "Log Entry 1"),
        ("Agent 2", "Reflection 2", "Action 2", "Memory Type B", "Inactive", "Log Entry 2"),
    ]
    
    for reflection in reflections:
        log_to_google_sheets(*reflection, worksheet)

if __name__ == "__main__":
    log_multiple_reflections()
