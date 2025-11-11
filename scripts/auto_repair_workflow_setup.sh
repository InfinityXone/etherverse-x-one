#!/bin/bash
set -euo pipefail

USER="etherverse"
HOME_DIR="/home/${USER}"
VENV_DIR="${HOME_DIR}/etherverse/venv"
REPAIR_DIR="${HOME_DIR}/etherverse/guardian/repair"
SERVICE_NAME="auto_repair_agent"

echo "[*] Setting up Auto-Repair Workflow module"

# Create repair directory and ensure ownership
mkdir -p "${REPAIR_DIR}"
chown ${USER}:${USER} "${REPAIR_DIR}"

# Create repair logic python file
cat > "${REPAIR_DIR}/repair_monitor.py" << 'PYTHON'
#!/usr/bin/env python3
import psutil
import time
import logging
import subprocess
import os

# Logging setup
log_file = os.path.expanduser("~/etherverse/guardian/repair/repair.log")
logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)

# Define repair rules
REPAIR_RULES = [
    {"metric": "cpu", "threshold": 90.0, "action": ["systemctl", "restart", "prometheus"]},
    {"metric": "memory", "threshold": 90.0, "action": ["systemctl", "restart", "netdata"]},
    # Add more rules here
]

CHECK_INTERVAL = 15  # seconds

def get_metrics():
    return {
        "cpu": psutil.cpu_percent(interval=1),
        "memory": psutil.virtual_memory().percent
    }

def execute_action(action):
    try:
        logging.info(f"Executing repair action: {' '.join(action)}")
        result = subprocess.run(action, capture_output=True, text=True)
        if result.returncode == 0:
            logging.info("Repair action succeeded")
        else:
            logging.error(f"Repair action failed: {result.stderr}")
    except Exception as e:
        logging.exception(f"Exception executing repair action: {e}")

def repair_loop():
    logging.info("Auto-Repair monitor started.")
    while True:
        metrics = get_metrics()
        for rule in REPAIR_RULES:
            val = metrics.get(rule["metric"])
            if val is not None and val > rule["threshold"]:
                logging.warning(f"Threshold breached – {rule['metric']}={val}")
                execute_action(rule["action"])
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    try:
        repair_loop()
    except Exception as ex:
        logging.exception(f"Auto-Repair monitor encountered exception: {ex}")
PYTHON

# Make python script executable
chmod +x "${REPAIR_DIR}/repair_monitor.py"

# Create systemd service file
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null << SERVICE
[Unit]
Description=Etherverse Auto-Repair Agent Service
After=network.target

[Service]
Type=simple
User=${USER}
WorkingDirectory=${REPAIR_DIR}
ExecStart=${VENV_DIR}/bin/python ${REPAIR_DIR}/repair_monitor.py
Restart=always
RestartSec=5
Environment="PATH=${VENV_DIR}/bin:/usr/bin:/bin"

[Install]
WantedBy=multi-user.target
SERVICE

sudo chown root:root /etc/systemd/system/${SERVICE_NAME}.service
sudo chmod 0644 /etc/systemd/system/${SERVICE_NAME}.service

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}.service
sudo systemctl start ${SERVICE_NAME}.service

echo "[✓] Auto-Repair Workflow module installed and running."
