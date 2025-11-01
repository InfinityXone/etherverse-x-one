#!/usr/bin/env bash
set -euo pipefail
NOTE="${1:-hello-etherverse}"
python3 "$HOME/etherverse-x-one/swarm_orchestrator.py" --kickoff "$NOTE"
