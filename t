// eslint.config.cjs (compatible ESLint 9)
const angular = require('eslint-plugin-angular');

module.exports = [
  {
    ignores: ['dist/**', 'node_modules/**'],
  },
  {
    files: ['src/**/*.js'],
    languageOptions: {
      ecmaVersion: 2021,
      sourceType: 'script',
      globals: {
        window: 'readonly',
        angular: 'readonly',
      },
    },
    plugins: { angular },
    rules: {
      // règles minimales
      'no-undef': 'warn',
      'no-unused-vars': 'warn',
      // quelques règles angular désactivées pour code legacy
      'angular/document-service': 'off',
    },
  },
];
