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
