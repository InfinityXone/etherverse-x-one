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
