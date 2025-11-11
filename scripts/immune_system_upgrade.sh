#!/bin/bash
set -euo pipefail

echo "[*] Starting Immune System Upgrade for Etherverse..."

# 1. Update system and install monitoring stack
sudo apt update && sudo apt install -y prometheus prometheus-node-exporter

# 2. Download & install Checkmk Raw Edition (monitoring UI & rule engine)
# Replace URL with latest version as available
wget https://download.checkmk.com/checkmk/2.4.0p10/check-mk-raw-2.4.0p10_0.bookworm_amd64.deb
sudo dpkg -i check-mk-raw-2.4.0p10_0.bookworm_amd64.deb || sudo apt --fix-broken install -y

# 3. Enable Prometheus & Node Exporter services
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl enable prometheus-node-exporter
sudo systemctl start prometheus-node-exporter

# 4. Configure Prometheus to scrape Node Exporter
cat << 'EOF' | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
- job_name: node
  static_configs:
    - targets: ['localhost:9100']
EOF

sudo systemctl restart prometheus

# 5. Create Guardian / Immune Agent daemon
mkdir -p ~/etherverse/guardian
cat > ~/etherverse/guardian/health_monitor.py << 'PYTHON'
import psutil, time, subprocess, logging

logging.basicConfig(filename='/home/$(whoami)/etherverse/guardian/health.log',
                    level=logging.INFO,
                    format='%(asctime)s %(levelname)s %(message)s')

THRESH_CPU = 80.0
THRESH_MEM = 80.0

while True:
    cpu = psutil.cpu_percent(interval=1)
    mem = psutil.virtual_memory().percent
    if cpu > THRESH_CPU or mem > THRESH_MEM:
        logging.warning(f'High usage detected: CPU={cpu}, MEM={mem}')
        subprocess.run(['systemctl', 'restart', 'prometheus'])
    time.sleep(10)
PYTHON

# 6. Setup Guardian service
cat > ~/etherverse/guardian/guardian.service << 'SERVICE'
[Unit]
Description=Etherverse Guardian Immune Agent Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /home/$(whoami)/etherverse/guardian/health_monitor.py
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
SERVICE

sudo mv ~/etherverse/guardian/guardian.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable guardian.service
sudo systemctl start guardian.service

echo "[✓] Immune System Upgrade complete – monitoring, self-healing daemon and agents are live."
