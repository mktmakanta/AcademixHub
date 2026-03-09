/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        serif: ['Georgia', 'Cambria', 'Times New Roman', 'serif'],
        sans: ['system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'sans-serif'],
      },
      typography: {
        DEFAULT: {
          css: {
            maxWidth: 'none',
            color: '#292929',
            lineHeight: '1.8',
            fontSize: '1.125rem',
            h1: { fontFamily: 'Georgia, serif' },
            h2: { fontFamily: 'Georgia, serif' },
            h3: { fontFamily: 'Georgia, serif' },
          },
        },
      },
    },
  },
  plugins: [],
};
