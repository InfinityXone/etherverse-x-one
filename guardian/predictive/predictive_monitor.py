#!/home/etherverse/etherverse/venv/bin/python
import psutil
import time
import logging
import subprocess

# Logging setup
logging.basicConfig(
    filename='/home/etherverse/etherverse/guardian/predictive/predictive.log',
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s'
)

THRESH_CPU = 80.0   # % CPU usage threshold
THRESH_MEM = 80.0   # % memory usage threshold
CHECK_INTERVAL = 10  # seconds

def restart_service(service_name):
    logging.info(f"Attempting to restart service: {service_name}")
    try:
        subprocess.run(['sudo', 'systemctl', 'restart', service_name], check=True)
        logging.info(f"Successfully restarted {service_name}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to restart {service_name}: {e}")

def monitor_loop():
    logging.info("Predictive monitor started.")
    while True:
        cpu = psutil.cpu_percent(interval=1)
        mem = psutil.virtual_memory().percent

        logging.debug(f"Metrics – CPU: {cpu}%, MEM: {mem}%")

        if cpu > THRESH_CPU or mem > THRESH_MEM:
            logging.warning(f"High usage detected – CPU: {cpu}%, MEM: {mem}%")
            # Example remedial action – restart the guardian service or monitoring service
            restart_service('guardian_predictive.service')

        time.sleep(CHECK_INTERVAL)

if __name__ == '__main__':
    try:
        monitor_loop()
    except Exception as ex:
        logging.exception(f"Predictive monitor encountered an exception: {ex}")
        # Optional graceful shutdown or restart
