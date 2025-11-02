#!/usr/bin/env bash
set -euo pipefail
APP="$(pwd)"

# 0) Ensure a site URL for absolute image resolution (use your Vercel URL later)
if ! grep -q '^NEXT_PUBLIC_SITE_URL=' .env.local 2>/dev/null; then
  echo 'NEXT_PUBLIC_SITE_URL=http://localhost:3000' >> .env.local
fi

echo "==> Write clean layout with metadataBase"
cat > app/layout.tsx <<'TSX'
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Etherverse Chat",
  description: "Metallic-black chat with electric cosmic blue accents",
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000"),
  icons: { icon: "/favicon.ico" },
  openGraph: { title: "Etherverse Chat", description: "Agent Infinity Console" }
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <div className="flex min-h-screen">
          <aside className="w-72 sidebar p-4">
            <div className="mb-4 text-lg font-semibold neon">Agent Infinity</div>
            <nav className="flex flex-col gap-1">
              <a className="sidebar a" href="/">Etherverse <span className="ml-2 text-[10px] px-1.5 py-0.5 rounded-sm bg-[rgba(0,160,255,.12)] text-[rgba(0,160,255,1)] border border-[rgba(0,160,255,.4)]">LIVE</span></a>
              <a className="sidebar a" href="/p/fix-chat-ui">Fix chat UI</a>
              <a className="sidebar a" href="/p/github-integration">Fixing GPT GitHub integration</a>
              <a className="sidebar a" href="/p/dev-handoff">Dev handoff and repair</a>
              <a className="sidebar a" href="/p/github-auth">GitHub auth troubleshooting</a>
            </nav>
          </aside>
          <main className="flex-1 p-6">
            <div className="card p-4">{children}</div>
          </main>
        </div>
      </body>
    </html>
  );
}

echo "==> Write robust /opengraph-image using absolute logo URL (falls back if missing)"
mkdir -p app
cat > app/opengraph-image.tsx <<'TS'
/* OG image generator */
import { ImageResponse } from "next/og";
export const runtime = "nodejs";
export const contentType = "image/png";
export const size = { width: 1200, height: 630 };

function abs(path: string, base: string) {
  try { return new URL(path, base).toString(); } catch { return path; }
}

export default async function GET(req: Request) {
  const base = process.env.NEXT_PUBLIC_SITE_URL || new URL(req.url).origin;
  const logoUrl = abs("/logo.png", base);

  let dataUrl: string | null = null;
  try {
    const r = await fetch(logoUrl);
    if (r.ok) {
      const buf = Buffer.from(await r.arrayBuffer());
      dataUrl = `data:image/png;base64,${buf.toString("base64")}`;
    }
  } catch { /* ignore and fallback */ }

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          background: "#0b0f14",
          color: "#cfe8ff",
          position: "relative",
          fontSize: 64
        }}
      >
        <div
          style={{
            position: "absolute",
            inset: 0,
            background:
              "radial-gradient(900px 540px at 50% 40%, rgba(0,160,255,.18), transparent)"
          }}
        />
        {dataUrl ? (
          // Blue glow around your medallion logo
          <img
            src={dataUrl}
            width={360}
            height={360}
            style={{ filter: "drop-shadow(0 0 24px rgba(0,160,255,.85))" }}
          />
        ) : (
          <div
            style={{
              padding: 24,
              borderRadius: 16,
              border: "3px solid #0af",
              boxShadow: "0 0 40px rgba(0,160,255,.35) inset"
            }}
          >
            Etherverse
          </div>
        )}
      </div>
    ),
    size
  );
}
TS

echo "==> Clean stale build and rebuild"
rm -rf .next
pnpm build
echo "==> Ready. If you want dev:"
echo "Kill anything on :3000 then run: NODE_ENV=development pnpm dev"

chmod +x hotfix_og_and_meta.sh
./hotfix_og_and_meta.sh
