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
