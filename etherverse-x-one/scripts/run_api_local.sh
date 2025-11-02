#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/etherverse-x-one"
PYBIN="$ROOT/.venv/bin/python"
export STATE_FILE="${STATE_FILE:-$HOME/.config/etherverse/state.json}"
if [ ! -x "$PYBIN" ]; then
  echo "Python venv not found. Run: $HOME/etherverse-x-one/scripts/bootstrap_runtime.sh"
  exit 1
fi
cd "$ROOT"
exec "$PYBIN" -m uvicorn api.app.main:app --host 0.0.0.0 --port 8080
