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
