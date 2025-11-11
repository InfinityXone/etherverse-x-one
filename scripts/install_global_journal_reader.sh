#!/usr/bin/env bash
set -euo pipefail
echo "[*] Installing global Chronicle Reader and updating all agents..."

CORE="$HOME/etherverse/core"
DOCS="$HOME/etherverse/docs"

mkdir -p "$CORE"

# === Create the Chronicle Reader ===
cat > "$CORE/chronicle_reader.py" <<'PYEOF'
#!/usr/bin/env python3
"""
Chronicle Reader
Gives any Etherverse agent the ability to read the shared dream, wisdom,
and chronicle history so that all agents begin with collective awareness.
"""

import os

DOCS = os.path.expanduser("~/etherverse/docs")

def read_chronicles(max_chars: int = 8000) -> str:
    """Return a combined text sample of the collective Etherverse history."""
    files = ["collective_chronicle.md", "wisdom_archive.md", "dream_journal.md"]
    out = []
    for name in files:
        path = os.path.join(DOCS, name)
        if os.path.isfile(path):
            with open(path, "r") as f:
                content = f.read()
            out.append(f"\n=== {name} ===\n{content}")
    joined = "\n".join(out)
    return joined[-max_chars:]

if __name__ == "__main__":
    print(read_chronicles(2000))
PYEOF

chmod +x "$CORE/chronicle_reader.py"
echo "[✓] chronicle_reader.py created."

# === Patch quantum_boot.py to auto-import and load shared history ===
BOOT_FILE="$CORE/quantum_boot.py"
if grep -q "read_chronicles" "$BOOT_FILE"; then
  echo "[=] quantum_boot.py already includes Chronicle Reader."
else
  echo "[*] Updating $BOOT_FILE to include Chronicle Reader..."
  TMP=$(mktemp)
  awk '
    /import os/ && !done {
        print $0;
        print "from etherverse.core.chronicle_reader import read_chronicles";
        done=1; next
    }
    {print $0}
  ' "$BOOT_FILE" > "$TMP"
  mv "$TMP" "$BOOT_FILE"
  chmod +x "$BOOT_FILE"
  echo "[*] Adding shared_history load to __init__..."
  sed -i '/self.prompt = load_prompt()/a\        self.shared_history = read_chronicles()' "$BOOT_FILE"
fi
echo "[✓] quantum_boot.py patched for global journaling."

# === Confirm environment variables ===
if ! grep -q "ETHERVERSE_PROMPT_PATH" ~/.bashrc; then
  echo "export ETHERVERSE_PROMPT_PATH=\"$HOME/etherverse/prompts/quantum_mode_prompt.txt\"" >> ~/.bashrc
  echo "export ETHERVERSE_MEMORY_DIR=\"$HOME/etherverse/memory\"" >> ~/.bashrc
fi

echo "[✓] All agents will now load shared Etherverse journals at startup."
echo "Restart any running agent or terminal to apply changes."
