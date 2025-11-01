#!/usr/bin/env bash
# ~/etherverse-x-one/fix_orchestrator_stack.sh
set -euo pipefail

ROOT="${HOME}/etherverse-x-one"
PKG="${ROOT}/etherverse_orchestrator"
STATE_DIR="${HOME}/.config/etherverse"
STATE_FILE="${STATE_DIR}/state.json"

echo "🔧 Repairing Etherverse Orchestrator Structure..."

mkdir -p "$ROOT" "$PKG" "$STATE_DIR"

# Create minimal package files (idempotent-safe)
cat > "${PKG}/__init__.py" <<'PY'
from .orchestrator import Orchestrator
from .hydration import hydrate_state, dehydrate_state, State
__all__ = ["Orchestrator", "hydrate_state", "dehydrate_state", "State"]
PY

cat > "${PKG}/hydration.py" <<'PY'
import json, os, time
from dataclasses import dataclass, asdict
from typing import Any, Dict, List

DEFAULT_STATE_PATH = os.path.expanduser("~/.config/etherverse/state.json")

@dataclass
class State:
    boot_ts: float
    items: List[Dict[str, Any]]

def hydrate_state(path: str = DEFAULT_STATE_PATH) -> State:
    if not os.path.exists(path):
        return State(boot_ts=time.time(), items=[])
    try:
        with open(path, "r", encoding="utf-8") as f:
            raw = json.load(f)
        return State(**raw)
    except Exception:
        # Corrupt or incompatible; start fresh but keep the file around
        return State(boot_ts=time.time(), items=[])

def dehydrate_state(state: State, path: str = DEFAULT_STATE_PATH) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(asdict(state), f, indent=2, sort_keys=True)
PY

cat > "${PKG}/orchestrator.py" <<'PY'
from typing import List, Dict, Any
from .hydration import State, hydrate_state, dehydrate_state

class Orchestrator:
    """
    Minimal orchestrator that:
      - Hydrates state on init
      - Allows enqueueing tasks
      - Dehydrates state on change
    """
    def __init__(self, state_path=None):
        self.state_path = state_path
        self.state: State = hydrate_state(state_path)  # boot on read

    def tasks(self) -> List[Dict[str, Any]]:
        return list(self.state.items)

    def enqueue(self, payload: Dict[str, Any]) -> None:
        self.state.items.append(payload)
        dehydrate_state(self.state, self.state_path)

    def summary(self) -> str:
        return f"{len(self.state.items)} task(s) tracked"
PY

# Create/replace swarm_orchestrator.py (entrypoint)
cat > "${ROOT}/swarm_orchestrator.py" <<'PY'
#!/usr/bin/env python3
import argparse, json, os, sys
from typing import Any, Dict
# Ensure local package is importable when run from anywhere
HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path: sys.path.insert(0, HERE)

from etherverse_orchestrator import Orchestrator, hydrate_state, dehydrate_state

def main() -> int:
    parser = argparse.ArgumentParser(prog="swarm_orchestrator")
    parser.add_argument("--state-file", default=os.path.expanduser("~/.config/etherverse/state.json"))
    parser.add_argument("--dry-run", action="store_true", help="Hydrate and print, no writes")
    parser.add_argument("--kickoff", default=None, help="Enqueue a simple kickoff task payload")
    parser.add_argument("--print-state", action="store_true", help="Dump full JSON state to stdout")
    args = parser.parse_args()

    # Hydrate
    st = hydrate_state(args.state_file)
    print(f"🧪 Hydrated {len(st.items)} item(s) from state")

    if args.dry_run and not args.kickoff and not args.print_state:
        print("✅ Dry-run complete (no changes).")
        return 0

    orch = Orchestrator(state_path=args.state_file)

    if args.kickoff:
        payload: Dict[str, Any] = {"type": "kickoff", "note": args.kickoff}
        orch.enqueue(payload)
        print(f"🚀 Enqueued kickoff: {json.dumps(payload)}")

    if args.print_state:
        print(json.dumps({"boot_ts": st.boot_ts, "items": [i for i in orch.tasks()]}, indent=2))

    print(f"📊 Orchestrator summary: {orch.summary()}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
PY

# Create a tiny smoke test
cat > "${ROOT}/test_orchestrator.py" <<'PY'
import os, json, tempfile, shutil
from etherverse_orchestrator import Orchestrator, hydrate_state

tmpdir = tempfile.mkdtemp(prefix="etherverse_test_")
try:
    state_file = os.path.join(tmpdir, "state.json")
    orch = Orchestrator(state_path=state_file)
    assert len(orch.tasks()) == 0, "fresh state should be empty"
    orch.enqueue({"type": "kickoff", "note": "test"})
    assert len(orch.tasks()) == 1, "enqueue should add one"
    st = hydrate_state(state_file)
    assert len(st.items) == 1, "hydration should reflect enqueued"
    print("✅ test_orchestrator OK")
finally:
    shutil.rmtree(tmpdir, ignore_errors=True)
PY

# Ensure a venv exists (optional)
if [ -d "${ROOT}/.venv" ]; then
  PYBIN="${ROOT}/.venv/bin/python"
else
  PYBIN="$(command -v python3 || true)"
fi

# Touch requirements.txt if missing (so future CI won’t choke)
if [ ! -f "${ROOT}/requirements.txt" ]; then
  cat > "${ROOT}/requirements.txt" <<'REQ'
# minimal placeholder; pin later if needed
uvicorn
fastapi
REQ
fi

# Initialize state file if missing
if [ ! -f "${STATE_FILE}" ]; then
  echo '{ "boot_ts": 0, "items": [] }' > "${STATE_FILE}"
fi

# Friendly end message
echo "✅ Orchestrator package scaffolded at ${PKG}"
echo "✅ Entry: ${ROOT}/swarm_orchestrator.py"
echo "✅ State file: ${STATE_FILE}"
echo "Run: python3 ${ROOT}/swarm_orchestrator.py --dry-run"
