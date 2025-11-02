#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/etherverse-x-one/frontend/chat-ui"
cd "$APP"

echo "==> Fixing next.config.ts (overwrite corrupted file)"
cat > next.config.ts <<'EOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Keep builds unblocked while you iterate on UI
  eslint: { ignoreDuringBuilds: true },

  // Silence multi-lockfile root warnings
  outputFileTracingRoot: __dirname,
};

export default nextConfig;

echo "==> Writing local .eslintrc.cjs"
cat > .eslintrc.cjs <<'EOF'
/** Etherverse UI local ESLint overrides */
module.exports = {
  root: true,
  extends: ["next/core-web-vitals", "next/typescript"],
  rules: {
    "@typescript-eslint/no-explicit-any": "off"
  }
};

# Helpful: make sure base URL is set for OG
if ! grep -q '^NEXT_PUBLIC_BASE_URL=' .env.local 2>/dev/null; then
  echo "NEXT_PUBLIC_BASE_URL=http://localhost:3000" >> .env.local
fi

# Starfield + glow CSS (only add if missing)
if [ -f app/globals.css ] && ! grep -q 'Starfield layer (ultra-light, GPU-friendly)' app/globals.css; then
  echo "==> Inject starfield + logo glow CSS"
  cat >> app/globals.css <<'CSS'

/* ====== Etherverse: Starfield layer (ultra-light, GPU-friendly) ====== */
body::before{
  content:"";
  position:fixed; inset:0; pointer-events:none;
  background:
    radial-gradient(2px 2px at 20% 30%, rgba(160,200,255,.45), transparent 60%),
    radial-gradient(1.5px 1.5px at 70% 80%, rgba(160,200,255,.35), transparent 60%),
    radial-gradient(1.8px 1.8px at 40% 60%, rgba(160,200,255,.25), transparent 60%);
  opacity:.25; animation:starDrift 40s linear infinite;
}
@keyframes starDrift {
  0% { transform: translate3d(0,0,0) scale(1); }
  50%{ transform: translate3d(-1.5%, -1.5%, 0) scale(1.02); }
  100%{transform: translate3d(0,0,0) scale(1); }
}

/* Logo glow */
.logo-glow{
  box-shadow:
    0 0 12px rgba(64,140,255,.45),
    0 0 28px rgba(64,140,255,.28),
    inset 0 0 8px rgba(140,200,255,.12);
  animation: logoPulse 2.6s ease-in-out infinite;
}
@keyframes logoPulse{
  0%{opacity:.9; filter: drop-shadow(0 0 4px rgba(70,130,255,.35));}
  50%{opacity:1; filter: drop-shadow(0 0 10px rgba(105,170,255,.6));}
  100%{opacity:.9; filter: drop-shadow(0 0 4px rgba(70,130,255,.35));}
}
CSS
fi

# Logo component (idempotent)
mkdir -p components app public .vercel
cat > components/Logo.tsx <<'TSX'
"use client";
type Props = { size?: number; className?: string };
export default function Logo({ size=32, className="" }: Props) {
  return (
    <div className={`relative inline-flex items-center justify-center ${className}`} style={{ width:size, height:size }}>
      <img src="/logo.png" width={size} height={size} alt="Infinity" className="select-none pointer-events-none rounded-md" draggable={false}/>
      <span className="absolute inset-0 rounded-md logo-glow" />
    </div>
  );
}

# Warn if logo missing (still continues)
if [ ! -f public/logo.png ]; then
  echo "⚠️  Put your logo at: $APP/public/logo.png (transparent PNG, ~512–1024px)."
fi
cp -f public/logo.png app/icon.png 2>/dev/null || true

# OG route (idempotent overwrite)
cat > app/opengraph-image.tsx <<'TSX'
import { ImageResponse } from "next/og";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";
export default async function OG(){
  return new ImageResponse(
    (<div style={{
      width:"100%",height:"100%",display:"flex",alignItems:"center",justifyContent:"center",
      background:"radial-gradient(1200px 700px at 60% 0%, rgba(60,110,255,.15), transparent), #070b12"
    }}>
      <div style={{
        display:"flex",gap:32,alignItems:"center",padding:48,borderRadius:24,
        border:"1px solid rgba(110,150,220,.45)",
        background:"linear-gradient(180deg, rgba(12,18,30,.95), rgba(6,10,18,.95))"
      }}>
        <img src="/logo.png" width={160} height={160} style={{ borderRadius: 12 }}/>
        <div style={{ display:"flex",flexDirection:"column" }}>
          <div style={{ fontSize: 60, color: "#eaf2ff", textShadow:"0 0 14px rgba(90,150,255,.8)" }}>Etherverse</div>
          <div style={{ fontSize: 28, color:"rgba(220,235,255,.85)" }}>Agent Infinity · LLM Chat Console</div>
        </div>
      </div>
    </div>), { ...size }
  );
}

# ---- Safe removal of any existing 'export const metadata = ...' in app/layout.tsx ----
LAYOUT="app/layout.tsx"
if [ -f "$LAYOUT" ]; then
  echo "==> Clean existing metadata export in app/layout.tsx"
  cp "$LAYOUT" "${LAYOUT}.bak"

  # AWK: skip from a line starting with 'export const metadata =' up to the next line that is just '};'
  awk '
    BEGIN{skip=0}
    skip==0 && $0 ~ /^export[[:space:]]+const[[:space:]]+metadata[[:space:]]*=/ { skip=1; next }
    skip==1 && $0 ~ /^};[[:space:]]*$/ { skip=0; next }
    skip==0 { print }
  ' "$LAYOUT" > "${LAYOUT}.clean" || true

  # Prepend our fresh metadata block
  cat > "${LAYOUT}.meta" <<'TSX'
// --- Etherverse metadata (injected) ---
export const metadata = {
  title: "Etherverse",
  description: "Agent Infinity Console",
  openGraph: {
    title: "Etherverse",
    description: "Agent Infinity · LLM Chat Console",
    url: process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000",
    siteName: "Etherverse",
    images: [{ url: "/opengraph-image", width: 1200, height: 630 }],
    type: "website",
  },
  icons: { icon: "/icon.png" },
};
// --- end injected metadata ---


  cat "${LAYOUT}.meta" "${LAYOUT}.clean" > "$LAYOUT"
  rm -f "${LAYOUT}.meta" "${LAYOUT}.clean"
else
  echo "==> WARNING: $LAYOUT not found; skipping metadata cleanup"
fi

# Vercel linkage (persist)
cat > .vercel/project.json <<'JSON'
{ "orgId": "BzPY8RK0uObFzDQUi6vdRr0s", "projectId": "prj_AqQGs01K6D6hcJWhbQA7SvqBGiAa" }
JSON

echo "==> Rebuild"
pnpm build

echo "==> Kill :3000 and launch dev"
lsof -i:3000 -t 2>/dev/null | xargs -r kill -9 || true
NODE_ENV=development pnpm dev
