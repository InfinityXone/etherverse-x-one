#!/bin/bash
set -euo pipefail

USER="etherverse"
HOME_DIR="/home/${USER}"
AGENT_DIR="${HOME_DIR}/etherverse/agents"
VENV_DIR="${HOME_DIR}/etherverse/venv"

echo "[*] Setting up Agent Kernel for Etherverse..."

# Activate virtual env
source "${VENV_DIR}/bin/activate"

# Install framework (choose one: MetaGPT or CrewAI)
pip install metagpt  # or: pip install crewai

# Create agent directory
mkdir -p "${AGENT_DIR}"
chown ${USER}:${USER} "${AGENT_DIR}"

# Create basic agent class file
cat > "${AGENT_DIR}/base_agent.py" << 'PYTHON'
class BaseAgent:
    def __init__(self, name, memory):
        self.name = name
        self.memory = memory  # memory engine object

    def retrieve(self, query, limit=5):
        return self.memory.search_memory(query=query, user_id=self.name, limit=limit)

    def log(self, text):
        self.memory.add_memory(text=text, user_id=self.name)

    def act(self, task):
        # placeholder: implement in subclass
        raise NotImplementedError("act() must be implemented by subclass")

if __name__ == "__main__":
    print("BaseAgent loaded.")
PYTHON

chown ${USER}:${USER} "${AGENT_DIR}/base_agent.py"

echo "[✓] Agent Kernel scaffold created at ${AGENT_DIR}"
deactivate
