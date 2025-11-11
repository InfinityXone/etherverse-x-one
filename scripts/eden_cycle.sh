#!/usr/bin/env bash
source ~/etherverse/venv/bin/activate
python - <<'PY'
import sqlite3, datetime, json
db = "~/etherverse/memory/persistent_memory.db"
conn = sqlite3.connect(db)
summary = {"time": datetime.datetime.utcnow().isoformat(), "note": "Eden cycle ping"}
conn.execute("INSERT INTO cycles(time,note) VALUES(?,?)", (summary["time"], summary["note"]))
conn.commit()
print(json.dumps(summary))
PY
