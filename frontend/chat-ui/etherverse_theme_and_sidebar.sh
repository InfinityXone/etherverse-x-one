#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/etherverse-x-one/frontend/chat-ui"
cd "$APP"

echo "==> Ensure PostCSS deps (Tailwind v4 style)"
pnpm add -D autoprefixer @tailwindcss/postcss tailwindcss tailwindcss-animate >/dev/null

echo "==> PostCSS config"
cat > postcss.config.mjs <<'EOF'
export default {
  plugins: {
    "@tailwindcss/postcss": {},
    autoprefixer: {},
  },
};

echo "==> Next config: pin roots (no experimental key)"
cat > next.config.ts <<'EOF'
import type { NextConfig } from "next";
import path from "path";

const config: NextConfig = {
  outputFileTracingRoot: path.join(__dirname),
  turbopack: { root: __dirname },
};
export default config;

echo "==> Tailwind config (keep defaults; no fancy tokens required)"
cat > tailwind.config.ts <<'EOF'
import type { Config } from "tailwindcss";

export default {
  content: [
    "./app/**/*.{ts,tsx,js,jsx,mdx}",
    "./components/**/*.{ts,tsx,js,jsx,mdx}",
    "./lib/**/*.{ts,tsx,js,jsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [require("tailwindcss-animate")],
} satisfies Config;

echo "==> Global CSS (metallic black + neon green, no @apply)"
mkdir -p app components
cat > app/globals.css <<'EOF'
@import "tailwindcss";

/* ===== Etherverse Dark Theme Tokens ===== */
:root{
  --bg: 240 6% 6%;           /* metallic black */
  --fg: 0 0% 100%;           /* white */
  --panel: 240 5% 8%;
  --border: 0 0% 65%;        /* thin silver */
  --muted: 240 5% 12%;
  --muted-fg: 0 0% 85%;
  --primary: 145 100% 50%;   /* electric neon green */
  --pop: 150 100% 49%;       /* alt neon */
}

/* Base */
*{-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale}
html,body{height:100%}
body{
  background-color:hsl(var(--bg));
  color:hsl(var(--fg));
  background-image:
     radial-gradient(1200px 600px at 20% -10%, rgba(255,255,255,0.06), transparent 60%),
     radial-gradient(1000px 500px at 110% 10%, rgba(80,255,170,0.08), transparent 60%),
     radial-gradient(900px 500px at 50% 120%, rgba(255,255,255,0.04), transparent 60%);
}

/* Scrollbars */
*::-webkit-scrollbar{width:10px;height:10px}
*::-webkit-scrollbar-thumb{background:hsl(var(--muted));border-radius:12px;border:2px solid transparent;background-clip:padding-box}

/* Reusable helpers (pure CSS so Tailwind doesn’t validate) */
.card{
  border:1px solid hsl(var(--border));
  background-color:hsl(var(--panel));
  border-radius:16px;
}
.neon{ text-shadow:0 0 12px hsl(var(--primary)/0.8),0 0 24px hsl(var(--primary)/0.5); }
.btn{
  display:inline-flex;align-items:center;justify-content:center;
  padding:.5rem 1rem;border-radius:12px;font-weight:600;
  border:1px solid hsl(var(--border));
  background:linear-gradient(180deg,hsl(var(--panel)) 0%,hsl(var(--bg)) 100%);
  transition:box-shadow .2s ease, transform .2s ease;
}
.btn:hover{ box-shadow:0 0 0 3px hsl(var(--primary)/.35); transform:translateY(-1px); }
.btn-primary{
  color:hsl(var(--bg));
  background:linear-gradient(180deg,hsl(var(--primary)) 0%, hsl(var(--pop)) 100%);
  border-color:transparent;
}
.input{
  width:100%;padding:.6rem .9rem;border-radius:12px;outline:none;
  border:1px solid hsl(var(--border)); background:hsl(var(--panel)); color:hsl(var(--fg));
}
.input:focus{ box-shadow:0 0 0 3px hsl(var(--primary)/.35); }

.sidebar{
  background:linear-gradient(180deg,hsl(var(--bg)) 0%, hsl(var(--panel)) 100%);
  border-right:1px solid hsl(var(--border));
}
.nav-item{
  display:flex;gap:.6rem;align-items:center;
  padding:.55rem .75rem;border-radius:12px;border:1px solid transparent;
  transition:background .15s ease, border-color .15s ease, box-shadow .15s ease;
}
.nav-item:hover{ background-color:hsl(var(--muted)); border-color:hsl(var(--border)); }
.nav-item.active{
  border-color:transparent;
  background:linear-gradient(180deg,hsl(var(--panel)) 0%, hsl(var(--bg)) 100%);
  box-shadow:0 0 0 2px hsl(var(--primary)/.65);
}
.badge{
  padding:.1rem .45rem;border:1px solid hsl(var(--border));border-radius:999px;
  font-size:.7rem;color:hsl(var(--muted-fg));
}

echo "==> Sidebar component"
cat > components/Sidebar.tsx <<'EOF'
"use client";
import { usePathname } from "next/navigation";
import Link from "next/link";
import { Folder, Gauge, MessageSquareText, Network, Eye } from "lucide-react";

type Item = { name: string; href: string; icon?: React.ReactNode; badge?: string };
const projects: Item[] = [
  { name: "Etherverse", href: "/" , icon: <Folder size={16}/> , badge:"LIVE"},
  { name: "Fix chat UI setup", href: "/p/fix-chat-ui", icon: <MessageSquareText size={16}/> },
  { name: "Fixing GPT GitHub integration", href: "/p/github-integration", icon: <Network size={16}/> },
  { name: "Dev handoff and repair", href: "/p/dev-handoff", icon: <Gauge size={16}/> },
  { name: "GitHub auth troubleshooting", href: "/p/github-auth", icon: <Eye size={16}/> },
];

export default function Sidebar(){
  const pathname = usePathname();
  return (
    <aside className="sidebar w-72 min-h-screen p-3">
      <div className="flex items-center gap-2 mb-4">
        <div className="h-8 w-8 rounded-xl"
             style={{background:"linear-gradient(135deg, hsl(var(--primary)) 0%, hsl(var(--pop)) 100%)"}}/>
        <div className="font-semibold text-lg neon">Agent Infinity</div>
      </div>

      <div className="text-xs uppercase tracking-wider text-[hsl(var(--muted-fg))] mb-2">
        Projects
      </div>
      <nav className="flex flex-col gap-1">
        {projects.map(p=>{
          const active = pathname===p.href;
          return (
            <Link key={p.name} href={p.href} className={`nav-item ${active ? "active" : ""}`}>
              <span className="opacity-90">{p.icon ?? <Folder size={16}/>}</span>
              <span className="flex-1">{p.name}</span>
              {p.badge && <span className="badge">{p.badge}</span>}
            </Link>
          )
        })}
      </nav>
    </aside>
  );
}

echo "==> Layout with sidebar"
cat > app/layout.tsx <<'EOF'
import "./globals.css";
import Sidebar from "@/components/Sidebar";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Etherverse Chat",
  description: "Metallic-black chat with neon accents",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <div className="min-h-screen grid" style={{gridTemplateColumns:"18rem 1fr"}}>
          <Sidebar />
          <main className="p-4 md:p-6">
            <div className="card p-4 md:p-6">
              {children}
            </div>
          </main>
        </div>
      </body>
    </html>
  );
}

echo "==> Example page with chat shell"
cat > app/page.tsx <<'EOF'
"use client";
import { useState } from "react";

export default function Page(){
  const [msg,setMsg] = useState("");
  const [log,setLog] = useState<string[]>([
    "Welcome to the Etherverse console. Type to talk to your agent."
  ]);

  async function send(){
    if(!msg.trim()) return;
    setLog(l=>[...l, `You: ${msg}`]);
    setMsg("");
    // placeholder echo; wire to your /api/chat
    setTimeout(()=> setLog(l=>[...l, "Agent: ⚡ neon thoughts engaged"]), 300);
  }

  return (
    <div className="flex flex-col gap-4">
      <h1 className="text-2xl font-semibold neon">LLM Chat Console</h1>

      <div className="card p-4 h-[55vh] overflow-auto">
        {log.map((l,i)=>(
          <div key={i} className="mb-2">{l}</div>
        ))}
      </div>

      <div className="flex items-center gap-2">
        <input
          className="input"
          value={msg}
          placeholder="Message Codex Ω∞..."
          onChange={e=>setMsg(e.target.value)}
          onKeyDown={e=>{ if(e.key==="Enter") send(); }}
        />
        <button className="btn btn-primary" onClick={send}>Send</button>
      </div>
    </div>
  );
}

echo "==> Optional stub pages for project links"
mkdir -p app/p
for slug in fix-chat-ui github-integration dev-handoff github-auth; do
cat > "app/p/$slug/page.tsx" <<EOF
export default function Pg(){ return <div className="space-y-3">
  <h2 className="text-xl font-semibold neon">$(echo "$slug" | tr '-' ' ' | sed 's/.*/\L&/; s/[a-z]*/\u&/g')</h2>
  <p className="text-[hsl(var(--muted-fg))]">Worklog goes here.</p>
</div>;}
done

echo "==> Clean build"
rm -rf .next node_modules/.cache 2>/dev/null || true
pnpm install >/dev/null
pnpm build
echo "✅ Theme + Sidebar ready. Start dev: pnpm dev"
