#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/etherverse-x-one"
VENV="$ROOT/.venv"
REQ="$ROOT/requirements.txt"

mkdir -p "$ROOT"
if [ ! -f "$REQ" ]; then
  cat > "$REQ" <<'REQ'
fastapi
uvicorn
pydantic
REQ
fi

# Create venv if missing
if [ ! -d "$VENV" ]; then
  python3 -m venv "$VENV"
fi

# Upgrade pip + install deps
"$VENV/bin/pip" install --upgrade pip wheel >/dev/null
"$VENV/bin/pip" install -r "$REQ"

# Smoke test
"$VENV/bin/python" - <<'PY'
import fastapi, uvicorn
print("✅ fastapi/uvicorn import OK")
PY

echo "✅ Runtime ready:"
echo "   Python: $("$VENV/bin/python" -V)"
echo "   Uvicorn: $("$VENV/bin/python" -m uvicorn --version 2>/dev/null || echo uvicorn OK)"
