#!/usr/bin/env bash
set -euo pipefail
APP="$HOME/etherverse-x-one/frontend/chat-ui"
cd "$APP"

echo "==> Cosmic Medallion Theme setup"

# 1) Add logo if not already there
mkdir -p public
if [ ! -f public/logo.png ]; then
  echo "⚠️  Place your Cosmic Medallion logo at: $APP/public/logo.png"
fi

# 2) Replace global styles
cat > app/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* ==== Cosmic Medallion Etherverse Theme ==== */
:root {
  --bg-dark: #0a0a0d;
  --bg-card: #121217;
  --accent-blue: #00bfff;
  --font-white: #e8ebf0;
  --border-color: #1c2233;
}

html, body {
  height: 100%;
  background: radial-gradient(circle at 50% 20%, #101018 0%, var(--bg-dark) 100%);
  color: var(--font-white);
  font-family: 'Inter', system-ui, sans-serif;
  letter-spacing: 0.02em;
  background-image: url("/logo.png");
  background-repeat: no-repeat;
  background-position: center 45%;
  background-size: 580px auto;
  background-blend-mode: soft-light;
}

.card {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  box-shadow: 0 0 8px rgba(0, 191, 255, 0.15);
  transition: box-shadow 0.3s ease;
}
.card:hover {
  box-shadow: 0 0 16px rgba(0, 191, 255, 0.35);
}

.sidebar {
  background: linear-gradient(180deg, #0c0c10 0%, #090a0f 100%);
  border-right: 1px solid var(--border-color);
}
.sidebar a {
  color: var(--font-white);
  border-left: 2px solid transparent;
  padding: 8px 12px;
  border-radius: 6px;
  transition: all 0.25s ease;
}
.sidebar a:hover,
.sidebar a.active {
  color: var(--accent-blue);
  border-left: 2px solid var(--accent-blue);
  background: rgba(0, 191, 255, 0.05);
}

.neon {
  color: var(--accent-blue);
  text-shadow: 0 0 6px rgba(0,191,255,0.4);
}

/* Scrollbar and glow */
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-thumb {
  background-color: rgba(0,191,255,0.3);
  border-radius: 8px;
}

/* Animated shimmer for titles */
@keyframes shimmer {
  0% { text-shadow: 0 0 4px rgba(0,191,255,.2); }
  50% { text-shadow: 0 0 14px rgba(0,191,255,.7); }
  100% { text-shadow: 0 0 4px rgba(0,191,255,.2); }
}
h1, h2, .title {
  animation: shimmer 3s ease-in-out infinite;
}
CSS

# 3) Sidebar header update
mkdir -p components
cat > components/SidebarHeader.tsx <<'TSX'
"use client";
import Logo from "./Logo";

export default function SidebarHeader() {
  return (
    <div className="flex items-center gap-3 mb-4">
      <Logo size={36} />
      <div className="text-lg font-semibold neon">Agent Infinity</div>
    </div>
  );
}

# 4) Glow logo component (same as before)
cat > components/Logo.tsx <<'TSX'
"use client";
type Props = { size?: number; className?: string };
export default function Logo({ size=36, className="" }: Props) {
  return (
    <div className={`relative inline-flex items-center justify-center ${className}`} style={{ width:size, height:size }}>
      <img src="/logo.png" width={size} height={size} alt="Infinity" className="rounded-md pointer-events-none select-none"/>
      <span className="absolute inset-0 rounded-md logo-glow" />
    </div>
  );
}

# 5) Add glow CSS
cat >> app/globals.css <<'CSS'

.logo-glow {
  box-shadow:
    0 0 12px rgba(0,191,255,.35),
    0 0 22px rgba(0,191,255,.25),
    inset 0 0 10px rgba(0,191,255,.15);
  animation: logoPulse 2.4s ease-in-out infinite;
}
@keyframes logoPulse {
  0% { opacity:.9; filter:drop-shadow(0 0 5px rgba(0,191,255,.4)); }
  50% { opacity:1; filter:drop-shadow(0 0 14px rgba(0,191,255,.9)); }
  100% { opacity:.9; filter:drop-shadow(0 0 5px rgba(0,191,255,.4)); }
}
CSS

echo "==> Rebuild with new theme"
pnpm build

echo "==> Kill anything on :3000"
lsof -i:3000 -t 2>/dev/null | xargs -r kill -9 || true

echo "==> Start dev server"
NODE_ENV=development pnpm dev
