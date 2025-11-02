import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './pages/**/*.{ts,tsx}',
    './src/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        ether: {
          black: '#000000',
          offA: '#050505',
          offB: '#0a0a0a',
          border: '#1a1a1a',
          text: '#e5e7eb',
          textDim: '#9ca3af',
          textGlow: '#dbe4ff',
          blue: '#1e3aff',
          blueDim: '#1123bf',
        },
      },
      boxShadow: {
        ether: '0 0 40px rgba(30,58,255,0.08)',
        'ether-sm': '0 0 20px rgba(30,58,255,0.06)',
      },
      ringColor: {
        ether: '#1e3aff',
      },
      keyframes: {
        'ether-pulse': {
          '0%, 100%': { boxShadow: '0 0 28px rgba(30,58,255,0.10)' },
          '50%': { boxShadow: '0 0 12px rgba(30,58,255,0.04)' },
        },
        'ether-bloom': {
          '0%': { opacity: '0', filter: 'blur(8px)' },
          '100%': { opacity: '1', filter: 'blur(0)' },
        },
      },
      animation: {
        'ether-pulse': 'ether-pulse 2.2s ease-in-out infinite',
        'ether-bloom': 'ether-bloom .35s ease-out both',
      },
      borderColor: {
        ether: '#1a1a1a',
      },
    },
  },
  plugins: [
    function({ addUtilities }) {
      addUtilities({
        '.ether-card': {
          backgroundColor: '#0a0a0a',
          border: '1px solid #1a1a1a',
          boxShadow: '0 0 40px rgba(30,58,255,0.08)',
          borderRadius: '0.75rem',
        },
        '.ether-input': {
          backgroundColor: '#0a0a0a',
          border: '1px solid #1a1a1a',
          color: '#e5e7eb',
        },
        '.ether-glow': {
          boxShadow: '0 0 40px rgba(30,58,255,0.10)',
        },
        '.ether-focus': {
          outline: 'none',
          boxShadow: '0 0 0 2px #1e3aff40',
          borderColor: '#1e3aff',
        },
      })
    },
  ],
}
export default config
