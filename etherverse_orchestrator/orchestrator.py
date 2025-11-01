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
