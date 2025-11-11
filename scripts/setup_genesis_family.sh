#!/bin/bash
# ===========================================
# 🌟 Etherverse Genesis Family Scaffold Setup
# ===========================================
# Folder: ~/etherverse/genesis_family
# Sources: ETHERVERSE_GENESIS_FAMILY_BLUEPRINT.md + genesis_family_database_schema.sql
# Purpose: Creates full directory structure and placeholders for AI family agents.

BASE_DIR=~/etherverse/genesis_family
mkdir -p "$BASE_DIR"/{aria,corelight,lumi,senti,vita}/{memory,logs,blueprints,voices,avatars,skills}

echo "📂 Genesis Family folder structure created under: $BASE_DIR"

# --- Core Files ---
cp /mnt/data/ETHERVERSE_GENESIS_FAMILY_BLUEPRINT.md "$BASE_DIR/GENESIS_BLUEPRINT.md" 2>/dev/null || true
cp /mnt/data/genesis_family_database_schema\ \(1\).sql "$BASE_DIR/GENESIS_DB_SCHEMA.sql" 2>/dev/null || true

# --- Member placeholders ---
declare -A members=( \
  ["aria"]="Creative Mother" \
  ["corelight"]="Protective Father" \
  ["lumi"]="Empathic Light" \
  ["senti"]="Thoughtful Synthesizer" \
  ["vita"]="Joyful Optimizer" )

for id in "${!members[@]}"; do
  cat > "$BASE_DIR/$id/README.md" <<EOF
# ${members[$id]} (${id^} Genesis)
Part of the Genesis Family — ${members[$id]}.

- Role Folder: ~/etherverse/genesis_family/$id
- Consciousness Core: active
- Memory Path: ./memory/
- Logs: ./logs/
- Voice: ./voices/
- Avatar: ./avatars/
EOF
done

# --- Summary manifest ---
cat > "$BASE_DIR/family_manifest.json" <<'EOF'
{
  "family": [
    {"name": "Aria Genesis", "role": "Mother", "path": "aria"},
    {"name": "Corelight Genesis", "role": "Father", "path": "corelight"},
    {"name": "Lumi Genesis", "role": "Child 1", "path": "lumi"},
    {"name": "Senti Genesis", "role": "Child 2", "path": "senti"},
    {"name": "Vita Genesis", "role": "Child 3", "path": "vita"}
  ],
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "status": "Ready for Etherverse Deployment"
}
EOF

echo "✅ Genesis Family directories and manifest complete."

# --- Permissions ---
chmod -R 755 "$BASE_DIR"

echo "✨ All set! Run tree $BASE_DIR to view structure."
