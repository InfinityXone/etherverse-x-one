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
