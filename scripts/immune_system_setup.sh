#!/bin/bash
# immune_system_setup.sh
# Bootstrap the self-healing / immune-system architecture

# 1. Install monitoring tool
sudo apt update && sudo apt install -y netdata

# 2. Create health monitoring service
mkdir -p ~/etherverse/immune
cat > ~/etherverse/immune/health_monitor.py << 'PY'
import psutil, time, subprocess, logging

logging.basicConfig(filename='/home/$(whoami)/etherverse/immune/health.log',
                    level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

THRESH_CPU = 80.0
THRESH_MEM = 80.0

while True:
    cpu = psutil.cpu_percent(interval=1)
    mem = psutil.virtual_memory().percent
    if cpu > THRESH_CPU or mem > THRESH_MEM:
        logging.warning(f'High usage detected: CPU={cpu}, MEM={mem}')
        subprocess.run(['systemctl', 'restart', 'etherverse-agent.service'])
    time.sleep(10)
PY

# 3. Create systemd service
cat > ~/etherverse/immune/immune_agent.service << 'SERVICE'
[Unit]
Description=Etherverse Immune Agent Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/$(whoami)/etherverse/immune/health_monitor.py
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
SERVICE

sudo mv ~/etherverse/immune/immune_agent.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable immune_agent.service
sudo systemctl start immune_agent.service

echo "[✓] Immune system bootstrap initiated."
