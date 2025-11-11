#!/usr/bin/env bash
source ~/etherverse/venv/bin/activate
export GATEWAY_PORT=8080
nohup python3 ~/etherverse/gateway.py > ~/etherverse/logs/gateway.stdout 2>&1 &
echo "[+] Gateway started"
