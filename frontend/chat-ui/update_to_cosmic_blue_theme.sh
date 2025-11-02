#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/etherverse-x-one/frontend/chat-ui"
cd "$APP"

echo "==> Updating globals.css for Cosmic-Blue Etherverse look"
cat > app/globals.css <<'EOF'
@import "tailwindcss";

:root {
  --bg: 220 15% 5%;
  --panel: 220 10% 8%;
  --border: 210 25% 45%;
  --primary: 210 100% 60%;
  --accent: 240 100% 85%;
  --fg: 0 0% 100%;
}

html,body{height:100%}
body{
  color:hsl(var(--fg));
  background-color:hsl(var(--bg));
  background-image:
    radial-gradient(1000px 700px at 70% -10%, rgba(70,110,255,0.07), transparent 70%),
    radial-gradient(800px 500px at 0% 110%, rgba(0,80,255,0.08), transparent 60%),
    radial-gradient(1200px 600px at 50% 0%, rgba(255,255,255,0.03), transparent 70%);
  background-blend-mode: overlay, normal;
  font-family: 'Inter', sans-serif;
}

.card {
  border: 1px solid hsl(var(--border));
  background:
    linear-gradient(180deg,hsl(var(--panel)) 0%,hsl(var(--bg)) 100%),
    radial-gradient(60% 40% at 50% 0%, rgba(255,255,255,0.05), transparent 70%);
  border-radius: 20px;
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,0.04),
    0 12px 40px rgba(0,0,0,0.35);
}

.neon {
  color: hsl(var(--accent));
  text-shadow:
    0 0 10px hsl(var(--primary)/0.9),
    0 0 25px hsl(var(--primary)/0.6);
}

.btn {
  border: 1px solid hsl(var(--border));
  border-radius: 12px;
  padding: .5rem 1rem;
  color: hsl(var(--fg));
  background: linear-gradient(180deg,hsl(var(--panel)) 0%,hsl(var(--bg)) 100%);
  transition: all .2s ease;
}
.btn:hover {
  box-shadow: 0 0 0 3px hsl(var(--primary)/.35);
  transform: translateY(-1px);
}
.btn-primary {
  background: linear-gradient(180deg,hsl(var(--primary)) 0%, hsl(var(--accent)) 100%);
  color: hsl(var(--bg));
  border-color: transparent;
  text-shadow: 0 0 6px hsl(var(--accent)/0.8);
}
.input {
  width: 100%;
  padding: .6rem .9rem;
  border-radius: 12px;
  border: 1px solid hsl(var(--border));
  background: hsl(var(--panel));
  color: hsl(var(--fg));
}
.input:focus {
  box-shadow: 0 0 0 3px hsl(var(--primary)/.35);
}
.sidebar {
  background: linear-gradient(180deg,hsl(var(--bg)) 0%, hsl(var(--panel)) 100%);
  border-right: 1px solid hsl(var(--border));
}
.nav-item {
  display: flex;
  gap: .6rem;
  align-items: center;
  padding: .55rem .75rem;
  border-radius: 12px;
  transition: all .15s ease;
}
.nav-item:hover {
  background: hsl(var(--panel));
}
.nav-item.active {
  background: linear-gradient(180deg,hsl(var(--panel)) 0%, hsl(var(--bg)) 100%);
  box-shadow: 0 0 0 2px hsl(var(--primary)/.6), 0 6px 26px hsl(var(--primary)/.1);
}

echo "==> Rebuild with the new theme"
pnpm build
NODE_ENV=development NEXT_PRIVATE_TURBOPACK_ROOT="$(pwd)" pnpm dev
