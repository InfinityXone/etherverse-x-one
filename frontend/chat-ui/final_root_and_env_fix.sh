#!/usr/bin/env bash
set -euo pipefail

CHAT="$HOME/etherverse-x-one/frontend/chat-ui"
REPO="$HOME/etherverse-x-one"

echo "==> 1) Normalize NODE_ENV for dev"
# Unset weird values from current shell
if [ "${NODE_ENV-}" != "" ] && [ "$NODE_ENV" != "development" ] && [ "$NODE_ENV" != "production" ] && [ "$NODE_ENV" != "test" ]; then
  echo "Unsetting non-standard NODE_ENV='$NODE_ENV'"
  unset NODE_ENV || true
fi
# Warn if any env files force NODE_ENV
grep -R --line-number -E '^\s*NODE_ENV\s*=' "$CHAT" "$REPO" 2>/dev/null || echo "No NODE_ENV in env files."

echo "==> 2) Stop Next from inferring your HOME as the monorepo root"
# These two are the usual offenders seen in your logs
rm -f "$HOME/package-lock.json" 2>/dev/null || true
rm -f "$REPO/package-lock.json" 2>/dev/null || true

echo "==> 3) Find and fix any stale next.config.* using experimental.outputFileTracingRoot"
# We fix within etherverse-x-one only (keeps scope tight)
mapfile -t NEXT_CFGS < <(find "$REPO" -maxdepth 3 -type f -regex '.*\/next\.config\.\(js\|mjs\|cjs\|ts\)$' 2>/dev/null | sort)
for cfg in "${NEXT_CFGS[@]}"; do
  if grep -q 'experimental.*outputFileTracingRoot' "$cfg"; then
    echo "Patching legacy experimental.outputFileTracingRoot in: $cfg"
    # Simple transform: remove the experimental key for OFTR; we’ll set at top-level in chat-ui below
    sed -i 's/outputFileTracingRoot[^,}]*[,}]//g' "$cfg" || true
    # also remove dangling "experimental: { }" if it became empty (safe no-op if not)
    sed -i 's/experimental:\s*{\s*}\s*,\?//g' "$cfg" || true
  fi
done

echo "==> 4) Ensure chat-ui has correct Next 15 config"
cat > "$CHAT/next.config.ts" <<'EOF'
import type { NextConfig } from "next";
import path from "path";

const config: NextConfig = {
  // Next 15: this lives at top-level (not under experimental)
  outputFileTracingRoot: path.join(__dirname),
  // Silence turbopack root warning
  turbopack: { root: __dirname },
};
export default config;

echo "==> 5) Sanity: Tailwind/PostCSS deps present"
cd "$CHAT"
pnpm add -D tailwindcss @tailwindcss/postcss autoprefixer tailwindcss-animate >/dev/null

# PostCSS v4-style config (if missing or drifted)
cat > postcss.config.mjs <<'EOF'
export default {
  plugins: {
    "@tailwindcss/postcss": {},
    autoprefixer: {},
  },
};

echo "==> 6) Clean install + build"
rm -rf node_modules .next
pnpm install
pnpm build

cat <<'TIP'

All set.

• Dev (clean env):   NODE_ENV=development pnpm dev
• Prod build:        NODE_ENV=production  pnpm build
• Vercel (pinned):   vercel --prod

If you still see root inference warnings, verify there are no other lockfiles above chat-ui:
  find "$HOME" -maxdepth 2 -name "package-lock.json" -o -name "pnpm-lock.yaml"

TIP
