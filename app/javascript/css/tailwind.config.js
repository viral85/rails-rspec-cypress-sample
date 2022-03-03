module.exports = {
  purge: [
    "./app/**/*.html.erb",
    "./app/**/*.html.haml",
    "./app/**/*.js"
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      spacing: {
        "18": "4.5rem",
        "65": "16.5rem",
        "68": "17rem"
      },
      colors:{
        "z-red": {
          light: "#fb876d",
          DEFAULT: "#FA6949",
          dark: "#f8350a"
        },

        "z-blue": {
          lightest: "#f3f8ff",
          light: "#4392fc",
          DEFAULT: "#1477FB",
          dark: "#045dd5"
        },

        "z-gray":{
          alternative: "#F0F0F0",
          lightest: "#F7F9FB",
          light: "#EFF2F9",
          lightbluish: "#8F98B9",
          creamybluish: "#e4eaf4",
          DEFAULT: "#39394B",
          dark: "#39394B"
        },
        "z-green": {
          light: "#5fd570",
          DEFAULT: "#37CB4C",
          dark: "#2ba43c"
        }
      }
    },
    listStyleType: {
       disc: 'disc',
       decimal: 'decimal'
    },
    maxHeight: {
      '192': '48rem',
      '0': '0',
      '1/4': '25%',
      '1/2': '50%',
      '3/4': '75%',
      'full': '100%',
    },
    container: {
      center: true,
      padding: {
        DEFAULT: '1rem',
        sm: '2rem'
      }
    },
    boxShadow: {
      none: "0 0 #0000",
      z: "0px 0px 11px rgba(20, 119, 251, 0.11)",
      "z-button": "0px 0px 11px rgba(20, 119, 251, 0.21)",
      "z-xl": "0 35px 60px -15px rgba(0, 0, 0, 0.3)",
      sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
      DEFAULT: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
      md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
      lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
      xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)'
    }
  },
  variants: {
    extend: {
      backgroundColor: ['active'],
      boxShadow: ['active']
    }
  },
  plugins: [],
}
