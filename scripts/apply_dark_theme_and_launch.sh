#!/bin/bash

set -e

echo "🧪 Applying custom Etherverse dark mode theme..."

# --- PATCH tailwind.config.js ---
cat > ~/etherverse-x-one/frontend/chat-ui/tailwind.config.js <<EOF
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}"
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        background: "#0a0a0a",     // metallic black
        border: "#aaaaaa",         // thin silver
        accent: "#39ff14",         // electric neon green
        text: "#ffffff",
      },
      borderRadius: {
        DEFAULT: "0.5rem",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
EOF

# --- PATCH globals.css ---
cat > ~/etherverse-x-one/frontend/chat-ui/app/globals.css <<EOF
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  @apply bg-background text-text;
}

input, textarea {
  @apply border border-border bg-black text-white;
}

button {
  @apply border border-border text-white hover:bg-accent;
}

.card, .menu, .chat-input {
  @apply border border-border bg-black text-white;
}
EOF

echo "✅ Tailwind + CSS theme updated."

# Go to frontend directory
cd ~/etherverse-x-one/frontend/chat-ui

echo "📦 Rebuilding project..."
pnpm install
pnpm build

echo "🚀 Launching local dev server on http://localhost:3000 ..."
pnpm dev
