#!/usr/bin/env bash
set -euo pipefail
APP="$HOME/etherverse-x-one/frontend/chat-ui"
cd "$APP"

echo "[i] Using app at: $APP"

# 0) Package manager detection
PM="pnpm"
command -v pnpm >/dev/null 2>&1 || PM="npm"

# 1) Fix Next.js config warning: move experimental.outputFileTracingRoot → outputFileTracingRoot
if [ -f next.config.ts ]; then
  echo "[i] Patching next.config.ts for outputFileTracingRoot…"
  sed -i 's/experimental:\s*{[^}]*outputFileTracingRoot[^}]*},\?//g' next.config.ts || true
  # If top-level key missing, add it just before export end
  if ! grep -q "outputFileTracingRoot" next.config.ts; then
    sed -i 's/export default defineConfig({/export default defineConfig({\n  outputFileTracingRoot: process.cwd(),/' next.config.ts || true
  fi
fi

# 2) Tailwind v4-safe global styles (no custom tokens required)
mkdir -p app components data public

cat > app/globals.css <<'CSS'
@import "tailwindcss";

:root {
  --bg: #0a0a0a;           /* metallic black-ish */
  --fg: #ffffff;           /* white text */
  --neon: #00ff66;         /* electric neon green */
  --muted: #9aa1a9;
  --card: #0f0f10;
  --panel: #0c0c0d;
  --border: #1a1a1d;
}

html, body, :root {
  height: 100%;
  background: var(--bg);
  color: var(--fg);
}

.neon-ring { box-shadow: 0 0 0 1px var(--neon); }
.neon-text { color: var(--neon); }
.neon-bg { background: var(--neon); color: #000; }
.panel { background: var(--panel); border: 1px solid var(--border); }
.card  { background: var(--card);  border: 1px solid var(--border); }
.scroll-slim::-webkit-scrollbar { width: 8px; height: 8px; }
.scroll-slim::-webkit-scrollbar-thumb { background: #262626; border-radius: 9999px; }
a { color: var(--neon); }
CSS

# 3) Sidebar data (Projects)
mkdir -p data
cat > data/projects.ts <<'TS'
export type Project = {
  id: string;
  name: string;
  repo?: string;
  status?: "healthy" | "degraded" | "down";
  url?: string;
};

export const projects: Project[] = [
  { id: "memory-gateway", name: "Memory Gateway", status: "healthy", url: "/p/dev-handoff" },
  { id: "infinity-agent", name: "Infinity Agent", status: "degraded" },
  { id: "codex-prime", name: "Codex Prime", status: "healthy" },
  { id: "construct-iq", name: "Construct-IQ", status: "down" },
];
TS

# 4) Sidebar component (metallic black + neon)
mkdir -p components
cat > components/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";
import { projects } from "@/data/projects";

const Dot = ({ status }: { status?: "healthy"|"degraded"|"down" }) => {
  const color =
    status === "healthy" ? "bg-[var(--neon)]" :
    status === "degraded" ? "bg-yellow-400" :
    "bg-red-500";
  return <span className={`inline-block h-2 w-2 rounded-full ${color}`} />;
};

export default function Sidebar() {
  return (
    <aside className="h-full w-72 shrink-0 panel p-4 pr-3 border-r border-[var(--border)]">
      <div className="flex items-center gap-2 mb-4">
        <div className="neon-bg px-2 py-0.5 rounded-md text-xs font-semibold">ETHERVERSE</div>
        <span className="text-sm text-[var(--muted)]">control</span>
      </div>

      <div className="mb-3 text-xs uppercase tracking-wider text-[var(--muted)]">Projects</div>
      <nav className="space-y-1 pr-1 overflow-auto scroll-slim" style={{maxHeight: "calc(100% - 56px)"}}>
        {projects.map(p => (
          <Link key={p.id} href={p.url || "#"} className="block">
            <div className="flex items-center justify-between group rounded-lg px-3 py-2 hover:bg-[#111] border border-transparent hover:border-[var(--border)]">
              <div className="flex items-center gap-2">
                <Dot status={p.status} />
                <span className="font-medium">{p.name}</span>
              </div>
              <span className="text-xs neon-text opacity-0 group-hover:opacity-100 transition-opacity">open</span>
            </div>
          </Link>
        ))}
      </nav>
    </aside>
  );
}
TSX

# 5) Simple Logo
cat > components/Logo.tsx <<'TSX'
export default function Logo() {
  return (
    <div className="flex items-center gap-2">
      <div className="neon-bg h-6 w-6 grid place-items-center rounded-lg font-black">∞</div>
      <div className="font-semibold tracking-wide">Etherverse Chat</div>
    </div>
  );
}
TSX

# 6) Layout with sidebar + metallic + neon accents
mkdir -p app
cat > app/layout.tsx <<'TSX'
import type { Metadata } from "next";
import "./globals.css";
import Sidebar from "@/components/Sidebar";
import Logo from "@/components/Logo";

export const metadata: Metadata = {
  title: "Etherverse Chat",
  description: "Metallic black with neon green accents",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-dvh">
        <div className="h-dvh flex">
          <Sidebar />
          <main className="flex-1 flex flex-col">
            <header className="h-14 flex items-center justify-between border-b border-[var(--border)] px-4">
              <Logo />
              <div className="flex items-center gap-2">
                <span className="text-sm text-[var(--muted)]">status</span>
                <span className="neon-text text-sm">online</span>
              </div>
            </header>
            <div className="flex-1 p-4 overflow-auto">
              <div className="card rounded-xl p-4 neon-ring">
                {children}
              </div>
            </div>
          </main>
        </div>
      </body>
    </html>
  );
}
TSX

# 7) Home page placeholder (keeps your assistant-ui pages intact)
cat > app/page.tsx <<'TSX'
export default function Page() {
  return (
    <div className="prose prose-invert max-w-none">
      <h1 className="neon-text">Welcome to Etherverse Chat</h1>
      <p>Metallic black UI with neon green accents and a Projects sidebar is ready.</p>
      <p>Hook your chat components into this page or route to your existing assistant-ui pages.</p>
    </div>
  );
}
TSX

# 8) Ensure tsconfig alias for "@/..."
if [ -f tsconfig.json ] && ! grep -q '"@/*"' tsconfig.json; then
  echo "[i] Adding @ alias to tsconfig.json…"
  node - <<'NODE'
const fs = require('fs');
const path = 'tsconfig.json';
const j = JSON.parse(fs.readFileSync(path,'utf8'));
j.compilerOptions = j.compilerOptions || {};
j.compilerOptions.baseUrl = j.compilerOptions.baseUrl || ".";
j.compilerOptions.paths = j.compilerOptions.paths || {};
j.compilerOptions.paths["@/*"] = ["./*"];
fs.writeFileSync(path, JSON.stringify(j,null,2));
NODE
fi

# 9) Install deps & launch dev
echo "[i] Installing deps…"
if [ "$PM" = "pnpm" ]; then
  pnpm install
  echo "[i] Starting dev server on port 3001 (if 3000 is taken)…"
  PORT=${PORT:-3000}
  (lsof -i :$PORT >/dev/null 2>&1 && export PORT=3001 || true)
  pnpm dev
else
  npm install
  echo "[i] Starting dev server on port 3001 (if 3000 is taken)…"
  PORT=${PORT:-3000}
  (lsof -i :$PORT >/dev/null 2>&1 && export PORT=3001 || true)
  npm run dev
fi
