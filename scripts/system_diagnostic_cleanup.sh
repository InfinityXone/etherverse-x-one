#!/bin/bash
echo "===== 🧠 Etherverse System Diagnostic & Cleanup ====="
date

# Step 1: Update and fix any broken packages
echo "[+] Updating package list..."
sudo apt update -y
echo "[+] Fixing broken packages..."
sudo apt --fix-broken install -y
sudo apt autoremove -y
sudo apt autoclean -y

# Step 2: Check disk usage and clean APT cache
echo "[+] Cleaning APT cache..."
sudo apt clean -y
echo "[+] Disk usage summary:"
df -h /

# Step 3: Detect duplicate files (safe report mode first)
echo "[+] Scanning for duplicate files..."
fdupes -r /home/etherverse > ~/etherverse/logs/duplicate_files_report.txt
echo "Duplicates saved to ~/etherverse/logs/duplicate_files_report.txt"

# Step 4: Find large files (>500MB)
echo "[+] Finding large files..."
find /home/etherverse -type f -size +500M -exec ls -lh {} \; > ~/etherverse/logs/large_files.txt
echo "Large file report saved to ~/etherverse/logs/large_files.txt"

# Step 5: Check for orphaned packages
echo "[+] Checking orphaned packages..."
sudo deborphan | tee ~/etherverse/logs/orphaned_packages.txt

# Step 6: Clear systemd logs (optional)
echo "[+] Clearing old logs..."
sudo journalctl --vacuum-time=3d

# Step 7: Memory and swap report
echo "[+] System memory and swap usage:"
free -h

# Step 8: List active daemons (for manual review)
echo "[+] Active services snapshot:"
systemctl list-units --type=service --state=running > ~/etherverse/logs/active_services.txt

echo "===== 🧩 Diagnostic Complete! ====="
