#!/bin/bash
set -e

echo "🌌 Fixing Tailwind dark theme setup..."

cd ~/etherverse-x-one/frontend/chat-ui

# Install tailwindcss-animate if missing
pnpm add -D tailwindcss-animate@latest

# Rewrite tailwind.config.js with proper safelist + working plugin
cat > tailwind.config.js <<EOF
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}"
  ],
  darkMode: "class",
  safelist: [
    "bg-background", "text-text", "border-border", "bg-black", "text-white"
  ],
  theme: {
    extend: {
      colors: {
        background: "#0a0a0a",  // metallic black
        border: "#aaaaaa",      // silver
        text: "#ffffff",
        accent: "#39ff14",      // neon green
      }
    },
  },
  plugins: [require("tailwindcss-animate")],
}
EOF

# Rewrite globals.css with standard classes
cat > app/globals.css <<EOF
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  @apply bg-black text-white;
}

input, textarea {
  @apply border border-gray-600 bg-black text-white;
}

button {
  @apply border border-gray-500 text-white hover:bg-green-500;
}

.card, .menu, .chat-input {
  @apply border border-gray-500 bg-black text-white;
}
EOF

echo "✅ Theme patched. Rebuilding..."

pnpm build

echo "🚀 Launching chat UI on http://localhost:3000 ..."
pnpm dev
