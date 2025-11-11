#!/bin/bash
set -euo pipefail

USER="etherverse"
HOME_DIR="/home/${USER}"
VENV_DIR="${HOME_DIR}/etherverse/venv"
SCRIPT_DIR="${HOME_DIR}/etherverse/guardian/predictive"
SERVICE_NAME="guardian_predictive"

echo "[*] Setting up systemd service for Predictive Guardian Agent"

# Ensure directory exists & ownership
sudo mkdir -p "${SCRIPT_DIR}"
sudo chown ${USER}:${USER} "${SCRIPT_DIR}"

# Create service file
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null << SERVICE
[Unit]
Description=Etherverse Predictive Guardian Agent Service
After=network.target

[Service]
Type=simple
User=${USER}
WorkingDirectory=${SCRIPT_DIR}
ExecStart=${VENV_DIR}/bin/python ${SCRIPT_DIR}/predictive_monitor.py
Restart=always
Environment="PATH=${VENV_DIR}/bin:/usr/bin:/bin"

[Install]
WantedBy=multi-user.target
SERVICE

sudo chown root:root /etc/systemd/system/${SERVICE_NAME}.service
sudo chmod 0644 /etc/systemd/system/${SERVICE_NAME}.service

sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}.service
sudo systemctl start ${SERVICE_NAME}.service

echo "[✓] Service ${SERVICE_NAME} installed and started."
