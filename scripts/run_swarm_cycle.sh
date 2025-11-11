#!/bin/bash
source "$HOME/etherverse/venv/bin/activate"
python3 "$HOME/etherverse/swarm_orchestrator.py" | tee "$HOME/etherverse/logs/swarm_cycle.log"
