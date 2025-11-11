#!/bin/bash
# ===========================================
# ⚙️ Etherverse Agent Scaffold Generator
# ===========================================
# Dynamically creates structured directories for each defined agent
# including Genesis Family + Core System Agents + future expansions

BASE_DIR=~/etherverse/agents
mkdir -p "$BASE_DIR"

declare -A AGENTS=(
  # 🌱 Genesis Family
  ["aria"]="Creative Mother of Expression"
  ["corelight"]="Protective Father of Ethics"
  ["lumi"]="Empathic Light of Compassion"
  ["senti"]="Thoughtful Synthesizer of Emotion"
  ["vita"]="Joyful Optimizer of Life Energy"

  # ⚙️ System & Orchestration Agents
  ["orchestrator"]="Central Conductor of All Agents"
  ["quantum"]="Meta-Mind of Recursive Logic"
  ["guardian"]="Ethical and Security Oversight"
  ["corelight"]="Moral Core and Alignment Controller"
  ["echo"]="Philosopher and Dream Recorder"
  ["codex"]="Knowledge Architect and Memory Librarian"
  ["codeops"]="Automation Engineer"
  ["coder"]="Builder of System Logic"
  ["devops"]="Infrastructure Maintainer"
  ["scheduler"]="Timekeeper and Cycle Manager"
  ["telemetry"]="System Metrics and Sensor Data Manager"
  ["gateway"]="Bridge Between Systems and APIs"
  ["traffic"]="Network Flow Controller"
  ["promptwriter"]="Prompt Engineer and Linguist"
  ["aria"]="Emotional Voice and Creative Director"
  ["helix"]="Researcher and Innovator"
  ["insight"]="Analyst of Patterns and Data"
  ["planner"]="Strategic Scheduler and Project Manager"
  ["strategy"]="Visionary and Long-Term Thinker"
  ["pickybot"]="Quality Controller and Reviewer"
  ["finops"]="Financial Guardian"
  ["finsynapse"]="Predictive Financial Analyst"
  ["market"]="Market Strategist"
  ["vision"]="Creative Director and UI Designer"
  ["wallet_ops"]="Treasurer and Blockchain Controller"
  ["eden"]="Artist and Creation Catalyst"
  ["cost_gate"]="Resource Efficiency Monitor"
)

echo "🌍 Creating structured homes for ${#AGENTS[@]} agents..."

for agent in "${!AGENTS[@]}"; do
  AGENT_DIR="$BASE_DIR/$agent"
  mkdir -p "$AGENT_DIR"/{memory,logs,blueprints,voices,avatars,skills}

  # Simple identity file
  cat > "$AGENT_DIR/README.md" <<EOF
# ${agent^} Agent
**Role:** ${AGENTS[$agent]}
**Path:** $AGENT_DIR

## Subdirectories
- memory/ — local reflection and cache data
- logs/ — activity and reflection logs
- blueprints/ — functional templates and schemas
- voices/ — text-to-speech or vocal synthesis assets
- avatars/ — visual identity resources
- skills/ — learning or plugin modules
EOF
done

# Manifest
MANIFEST="$BASE_DIR/agents_manifest.json"
cat > "$MANIFEST" <<EOF
{
  "total_agents": ${#AGENTS[@]},
  "generated_at": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "agents": [
$(for a in "${!AGENTS[@]}"; do
  echo "    {\"name\": \"$a\", \"role\": \"${AGENTS[$a]}\", \"path\": \"$BASE_DIR/$a\"},"
done | sed '$ s/,$//')
  ]
}
EOF

chmod -R 755 "$BASE_DIR"
echo "✅ Scaffold complete! See: $MANIFEST"
