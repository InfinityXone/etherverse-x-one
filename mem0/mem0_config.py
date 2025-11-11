"""
Local lightweight Mem0 replacement.
Stores short-term memories in SQLite for persistence and recall.
"""

import os, sqlite3, json

DB_PATH = os.path.expanduser("~/etherverse/mem0/history.db")
os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)

class Memory:
    def __init__(self, path=DB_PATH):
        self.conn = sqlite3.connect(path)
        self.conn.execute("""
            CREATE TABLE IF NOT EXISTS memories(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT,
                text TEXT,
                meta TEXT,
                created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        self.conn.commit()

    def add(self, text, user_id="system", meta=None):
        meta_json = json.dumps(meta or {})
        self.conn.execute(
            "INSERT INTO memories(user_id,text,meta) VALUES(?,?,?)",
            (user_id, text, meta_json)
        )
        self.conn.commit()

    def search(self, query=None, user_id="system", limit=5):
        rows = self.conn.execute(
            "SELECT text FROM memories WHERE user_id=? ORDER BY id DESC LIMIT ?",
            (user_id, limit)
        ).fetchall()
        return [r[0] for r in rows]

memory = Memory()

def add_memory(text: str, user_id: str = "agent"):
    memory.add(text=text, user_id=user_id, meta={})

def search_memory(query: str = "", user_id: str = "agent", limit: int = 5):
    return memory.search(query=query, user_id=user_id, limit=limit)

if __name__ == "__main__":
    print("Local Mem0 (SQLite) setup complete.")
