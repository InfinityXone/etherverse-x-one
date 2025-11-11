#!/usr/bin/env bash
# ============================================================
# 🚀 ETHERVERSE TURBO MODEL DOWNLOADER
# Installs aria2, adds swap for stability, and downloads Phi-3.
# Works on Chromebook (Crostini) or Debian-based systems.
# ============================================================

set -euo pipefail

MODEL_URL="https://huggingface.co/microsoft/Phi-3-mini-4k-instruct/resolve/main/model.gguf"
MODEL_DIR="$HOME/.ollama/models/phi3"
MODEL_FILE="$MODEL_DIR/model.gguf"
SWAPFILE="/swapfile"
SWAPSIZE="4G"

echo "==============================================="
echo "🚀 Etherverse Turbo Model Downloader"
echo "Target model: Phi-3 Mini (3.8B)"
echo "Destination:  $MODEL_FILE"
echo "==============================================="

# --- STEP 1: Install aria2 if missing ---
if ! command -v aria2c >/dev/null 2>&1; then
  echo "[*] Installing aria2..."
  sudo apt update -y && sudo apt install -y aria2
else
  echo "[✓] aria2 already installed."
fi

# --- STEP 2: Optional Swap Setup for Stability ---
if ! sudo swapon --show | grep -q "$SWAPFILE"; then
  echo "[*] Setting up ${SWAPSIZE} swapfile for smoother download..."
  sudo fallocate -l $SWAPSIZE $SWAPFILE || sudo dd if=/dev/zero of=$SWAPFILE bs=1M count=4096
  sudo chmod 600 $SWAPFILE
  sudo mkswap $SWAPFILE >/dev/null
  sudo swapon $SWAPFILE
else
  echo "[✓] Swap already active."
fi

# --- STEP 3: Tune memory parameters ---
echo "[*] Optimizing memory handling..."
sudo sysctl -w vm.swappiness=10 >/dev/null
sudo sysctl -w vm.vfs_cache_pressure=50 >/dev/null

# --- STEP 4: Create model directory ---
mkdir -p "$MODEL_DIR"

# --- STEP 5: Download with aria2 (resume, parallel) ---
echo "[*] Starting high-speed download..."
aria2c -c -x 16 -s 16 --file-allocation=none \
  --retry-wait=10 --max-tries=0 \
  -d "$MODEL_DIR" -o "model.gguf" "$MODEL_URL"

# --- STEP 6: Verify download ---
if [ -f "$MODEL_FILE" ]; then
  echo "[✅] Phi-3 model successfully downloaded to:"
  echo "     $MODEL_FILE"
  echo "[⚙️] You can now run: ollama run phi3"
else
  echo "[❌] Download failed or incomplete. Check your internet connection."
fi

# --- STEP 7: Summary ---
echo "==============================================="
echo "Etherverse Turbo Downloader complete!"
echo "Model stored at: $MODEL_FILE"
echo "To start the model: ollama run phi3"
echo "==============================================="
