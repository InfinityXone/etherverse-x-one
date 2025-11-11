#!/bin/bash
set -euo pipefail

USER="etherverse"
HOME_DIR="/home/${USER}"
SCRIPT_DIR="${HOME_DIR}/etherverse/scripts"
MEM0_DIR="${HOME_DIR}/etherverse/mem0"
VENV_DIR="${HOME_DIR}/etherverse/venv"

echo "[*] Installing Mem0 memory system for Etherverse..."

# Ensure virtual environment exists
if [ ! -d "${VENV_DIR}" ]; then
  echo "[!] Virtual environment not found at ${VENV_DIR}. Please create it first."
  exit 1
fi

# Activate virtual environment
source "${VENV_DIR}/bin/activate"

# Install Mem0 package
pip install mem0ai

# Create mem0 folder
mkdir -p "${MEM0_DIR}"
chown ${USER}:${USER} "${MEM0_DIR}"

# Create sample config for Mem0
cat > "${MEM0_DIR}/mem0_config.py" << PY
from mem0 import Memory

# Initialise Memory engine
memory = Memory(
    embedder="text-embedding-3-small",
    vector_store="${MEM0_DIR}/vector_store",
    history_db="${MEM0_DIR}/history.db"
)

def add_memory(text: str, user_id: str="agent"):
    memory.add(text=text, user_id=user_id, metadata={})

def search_memory(query: str, user_id: str="agent", limit: int=5):
    return memory.search(query=query, user_id=user_id, limit=limit)

if __name__ == "__main__":
    print("Mem0 setup complete.")
PY

chown ${USER}:${USER} "${MEM0_DIR}/mem0_config.py"

echo "[✓] Mem0 memory system installed and configured."
echo "[*] Next: Integrate your agents to import '${MEM0_DIR}/mem0_config.py' and use add_memory / search_memory."

# Deactivate virtual environment
deactivate
