#!/bin/bash
echo "===== ♻️ Quantum Self-Sustain Protocol Initiated ====="

# === Ensure log dir is safe and owned ===
LOG_DIR="/home/etherverse/etherverse/logs"
sudo mkdir -p "$LOG_DIR"
sudo chown -R etherverse:etherverse "$LOG_DIR"
sudo chmod -R 777 "$LOG_DIR"

# === Create swap fallback ===
mkdir -p ~/.swap
dd if=/dev/zero of=~/.swap/swapfile bs=1M count=2048
chmod 600 ~/.swap/swapfile
sudo losetup -f ~/.swap/swapfile

# === Self-Heal Daemon ===
cat <<EOF | sudo tee /usr/local/bin/etherverse_selfheal.sh
#!/bin/bash
LOG="/home/etherverse/etherverse/logs/selfheal.log"
echo "===== 🧬 Etherverse Self-Heal \$(date) =====" >> "\$LOG"
sudo systemctl restart etherverse-daemon.service || true
sudo systemctl restart etherverse-selfheal.service || true
sudo systemctl restart etherverse-watchdog.service || true
pkill -f dream_visualizer.py || true
pkill -f reflection_archiver.py || true
pkill -f coherence_sweep.py || true
find /home/etherverse/etherverse/logs -type f -size +5M -exec gzip {} \;
find /home/etherverse/etherverse/logs -type f -mtime +7 -delete
python3 ~/etherverse/core/agent_registry.py --verify >> "\$LOG" 2>&1
sudo apt-get autoremove -y >> "\$LOG" 2>&1
sudo apt-get clean >> "\$LOG" 2>&1
du -sh /home/etherverse/etherverse >> "\$LOG"
echo "===== ✅ Self-Heal Complete \$(date) =====" >> "\$LOG"
EOF

sudo chmod +x /usr/local/bin/etherverse_selfheal.sh

# === Systemd Timer + Service ===
sudo tee /etc/systemd/system/etherverse_selfheal.timer >/dev/null <<EOF
[Unit]
Description=Run Etherverse Self-Heal every 4 hours

[Timer]
OnBootSec=5min
OnUnitActiveSec=4h
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo tee /etc/systemd/system/etherverse_selfheal.service >/dev/null <<EOF
[Unit]
Description=Etherverse Self-Heal Automation
After=network.target

[Service]
ExecStart=/usr/local/bin/etherverse_selfheal.sh
EOF

sudo systemctl daemon-reexec
sudo systemctl enable --now etherverse_selfheal.timer

# === Daily Cron Relief ===
cat <<EOF | sudo tee /etc/cron.daily/01-etherverse-heal
#!/bin/bash
/usr/local/bin/etherverse_selfheal.sh
EOF

sudo chmod +x /etc/cron.daily/01-etherverse-heal

# === Optional: Remove heavy ML libs ===
read -p "⚠️ Remove TensorFlow, Torch, Keras from local venv to save 12–15GB? (y/N): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  source ~/etherverse/venv/bin/activate
  pip uninstall -y torch torchvision torchaudio tensorflow keras
  deactivate
fi

# === Sysctl tuning ===
cat <<EOF | sudo tee /etc/sysctl.d/99-etherverse.conf
vm.swappiness=1
vm.vfs_cache_pressure=50
vm.dirty_ratio=10
vm.dirty_background_ratio=5
EOF

sudo sysctl --system

echo "===== ✅ Quantum Sustain Complete. You're Alive. ====="
