#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/etherverse-x-one/frontend/chat-ui"
cd "$APP_DIR"

echo "==> Ensuring Node 20 and pnpm are present"
node -v || true
if ! node -v | grep -q "^v20"; then
  echo "Node 20 not active. You already installed it; continuing."
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "Installing pnpm globally (sudo required)..."
  sudo npm install -g pnpm
fi

echo "==> Lock to pnpm; remove any local npm install artifacts"
rm -f package-lock.json
rm -rf node_modules

echo "==> Install deps with pnpm"
pnpm install

echo "==> Add missing plugin used by tailwind config"
pnpm add -D tailwindcss-animate

# Create/replace Tailwind config for token-based theme (Tailwind v4 compatible)
cat > tailwind.config.ts << 'EOF'
import type { Config } from "tailwindcss";

export default {
  content: [
    "./app/**/*.{ts,tsx,js,jsx,mdx}",
    "./components/**/*.{ts,tsx,js,jsx,mdx}",
    "./lib/**/*.{ts,tsx,js,jsx}",
  ],
  theme: {
    extend: {
      colors: {
        // HSL variables defined in globals.css
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        card: "hsl(var(--card))",
        "card-foreground": "hsl(var(--card-foreground))",
        border: "hsl(var(--border))",
        ring: "hsl(var(--ring))",
        primary: "hsl(var(--primary))",
        "primary-foreground": "hsl(var(--primary-foreground))",
        muted: "hsl(var(--muted))",
        "muted-foreground": "hsl(var(--muted-foreground))",
        pop: "hsl(var(--pop))", // neon accent
      },
      borderRadius: {
        xl: "1rem",
        "2xl": "1.25rem",
      },
      boxShadow: {
        silver: "0 0 0 1px hsl(var(--border))",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
} satisfies Config;

# Tailwind v4 uses the @tailwindcss/postcss plugin via postcss config
cat > postcss.config.mjs << 'EOF'
export default {
  plugins: {
    "@tailwindcss/postcss": {},
    autoprefixer: {},
  },
};

mkdir -p app styles

# Global CSS with metallic black, thin silver borders, neon green accents
cat > app/globals.css << 'EOF'
@import "tailwindcss";

:root {
  /* Metallic black feel */
  --background: 240 6% 6%;
  --foreground: 0 0% 100%;

  /* Cards slightly lifted from bg */
  --card: 240 5% 8%;
  --card-foreground: 0 0% 100%;

  /* Thin silver border */
  --border: 0 0% 65%;

  /* Primary = electric neon green */
  --primary: 145 100% 50%;
  --primary-foreground: 240 6% 6%;

  --muted: 240 5% 12%;
  --muted-foreground: 0 0% 85%;

  /* Additional pop accent if needed */
  --pop: 150 100% 49%;
}

/* Smooth fonts */
* { -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; }

html, body {
  height: 100%;
}

body {
  @apply bg-background text-foreground;
  background-image:
    radial-gradient(1200px 600px at 20% -10%, rgba(255,255,255,0.06), transparent 60%),
    radial-gradient(1000px 500px at 110% 10%, rgba(80,255,170,0.08), transparent 60%),
    radial-gradient(900px 500px at 50% 120%, rgba(255,255,255,0.04), transparent 60%);
}

/* Reusable “thin silver border” card */
.card {
  @apply rounded-2xl shadow-silver border border-[hsl(var(--border))] bg-card text-[hsl(var(--card-foreground))];
}

/* Accent utilities */
.neon {
  text-shadow: 0 0 12px hsl(var(--primary)/0.8), 0 0 24px hsl(var(--primary)/0.5);
}
.accent-ring {
  box-shadow: 0 0 0 2px hsl(var(--primary)/0.75);
}

/* Buttons */
.btn {
  @apply inline-flex items-center justify-center rounded-xl px-4 py-2 font-medium transition;
  @apply border border-[hsl(var(--border))];
  background: linear-gradient(180deg, hsl(var(--card)) 0%, hsl(var(--background)) 100%);
}
.btn-primary {
  @apply text-[hsl(var(--primary-foreground))];
  background: linear-gradient(180deg, hsl(var(--primary)) 0%, hsl(var(--pop)) 100%);
}

/* Inputs: thin silver border, dark */
.input {
  @apply w-full rounded-xl border border-[hsl(var(--border))] bg-[hsl(var(--card))] px-4 py-2 text-foreground outline-none;
}
.input:focus {
  @apply ring-2;
  --tw-ring-color: hsl(var(--primary)/0.6);
}

# Ensure layout imports globals and applies body class
if [ -f app/layout.tsx ]; then
  sed -i '1i import "./globals.css";' app/layout.tsx || true
  # inject body class if not present
  if ! grep -q 'className=' app/layout.tsx; then
    sed -i 's/<body>/<body className="min-h-screen bg-background text-foreground">/' app/layout.tsx || true
  fi
fi

# Next.js: stop workspace confusion by pinning tracing root to app dir
cat > next.config.ts << 'EOF'
import type { NextConfig } from "next";
import path from "path";

const config: NextConfig = {
  experimental: {
    outputFileTracingRoot: path.join(__dirname),
  },
};
export default config;

echo "==> Approve optional native build scripts (sharp, oxide) so pnpm is happy"
pnpm approve-builds || true

echo "==> Build"
pnpm build

echo "==> Local dev hint"
echo "Run: pnpm dev  # will choose a free port if 3000 busy"

echo "==> Vercel deploy (requires your env already set)"
echo "Deploy: vercel --prod"
