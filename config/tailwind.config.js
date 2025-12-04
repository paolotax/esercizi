const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/components/**/*.{erb,css,rb}'
  ],
  theme: {
    extend: {
      colors: {
        'sky-light': '#C7EAFB',
        'custom-pink': '#C657A0',
        'custom-blue': '#C7EAFB',
        'custom-green': '#28A745',
        'custom-yellow': '#FFC107',
        'custom-purple': '#6F42C1',
        'custom-orange': '#FD7E14',
        'custom-red': '#DC3545',
        'custom-gray': '#6C757D',
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      keyframes: {
        shake: {
          '0%, 100%': { transform: 'translateX(0)' },
          '10%, 30%, 50%, 70%, 90%': { transform: 'translateX(-10px)' },
          '20%, 40%, 60%, 80%': { transform: 'translateX(10px)' },
        }
      },
      animation: {
        shake: 'shake 0.5s ease-in-out',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
    ({ addVariant }) => { 
      addVariant('hotwire-native', 'html[data-hotwire-native-app] &');
      addVariant('not-hotwire-native', 'html:not([data-hotwire-native-app]) &');
    }
  ]
}
