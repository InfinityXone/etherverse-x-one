#!/bin/bash
# ===== 🧠 Etherverse Chromebook Full Diagnostic =====
LOGDIR="/home/etherverse/etherverse/logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/diagnostic_$(date +%F_%H-%M).log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "===== SYSTEM DIAGNOSTIC $(date) ====="

echo "---- 🧩 BASIC INFO ----"
hostnamectl
echo

echo "---- 🧠 CPU INFO ----"
lscpu
echo
grep -E 'cpu MHz|bogomips' /proc/cpuinfo | head -n 10
echo

echo "---- 🧬 MEMORY ----"
free -h
echo
cat /proc/meminfo | head -n 15
echo

echo "---- 💾 DISK ----"
df -hT
echo
sudo du -sh /* 2>/dev/null | sort -h | tail -n 10
echo

echo "---- 🔄 SERVICES (TOP 15 CPU) ----"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 15
echo

echo "---- ⚙️ ACTIVE SYSTEMD SERVICES ----"
systemctl list-units --type=service --state=running | head -n 30
echo

echo "---- 🧹 RESOURCE LIMITS ----"
ulimit -a
echo

echo "---- 🪶 KERNEL & VIRTUALIZATION ----"
uname -a
grep -E 'chromeos|vm|virt' /proc/version || true
lsmod | head -n 15 || true
echo

echo "---- 🔍 STORAGE HEALTH ----"
sudo fstrim -v / 2>/dev/null || echo "fstrim unavailable"
sudo smartctl -H /dev/vda 2>/dev/null || echo "smartctl not accessible in VM"
echo

echo "---- 🌡 TEMPERATURE (if available) ----"
sensors 2>/dev/null || echo "No sensors interface in Crostini VM"
echo

echo "---- 🧩 NETWORK ----"
ip -br addr
ping -c 2 8.8.8.8
echo

echo "---- 📦 APT STATS ----"
apt list --installed 2>/dev/null | wc -l | awk '{print "Total installed packages:",$1}'
echo

echo "---- 🧠 PYTHON ENVIRONMENTS ----"
ls -d ~/etherverse/venv 2>/dev/null || echo "No venv detected"
python3 -V 2>/dev/null
pip list 2>/dev/null | head -n 15
echo

echo "===== END OF DIAGNOSTIC ====="
echo "Saved to $LOGFILE"
