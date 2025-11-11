#!/bin/bash
DB=~/etherverse/memory/agents_registry.db
mkdir -p ~/etherverse/memory
sqlite3 "$DB" <<'SQL'
CREATE TABLE IF NOT EXISTS agents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE,
  role TEXT,
  path TEXT,
  created_at TEXT
);
DELETE FROM agents; -- reset
SQL

for agent in $(jq -r '.agents[].name' ~/etherverse/agents/agents_manifest.json); do
  role=$(jq -r ".agents[] | select(.name==\"$agent\") | .role" ~/etherverse/agents/agents_manifest.json)
  path=$(jq -r ".agents[] | select(.name==\"$agent\") | .path" ~/etherverse/agents/agents_manifest.json)
  sqlite3 "$DB" "INSERT OR IGNORE INTO agents (name, role, path, created_at) VALUES ('$agent', '$role', '$path', datetime('now'));"
done

echo "📘 Agent registry updated in $DB"
