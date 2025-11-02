#!/usr/bin/env bash
set -euo pipefail

# Sanitized wrapper for legacy full_autonomous_setup
# The legacy version was moved to ops/_legacy/scripts/full_autonomous_setup_safe.sh
# This wrapper keeps the entrypoint name stable and enforces DATA_ROOT usage.

export DATA_ROOT="${DATA_ROOT:-${DATA_ROOT:-/mnt/data}}"

echo "[i] full_autonomous_setup wrapper"
echo "    DATA_ROOT=$DATA_ROOT"
echo "    Calling legacy script from ops/_legacy…"

LEGACY_SCRIPT="$(dirname "$0")/../ops/_legacy/scripts/full_autonomous_setup_safe.sh"
if [ ! -x "$LEGACY_SCRIPT" ]; then
  echo "[!] Legacy script missing or not executable: $LEGACY_SCRIPT"
  exit 1
fi

# Forward all args
exec "$LEGACY_SCRIPT" "$@"
