webpack.config.js

const path = require('path');

module.exports = {
  mode: 'development',

  // 👇 Entry minimal pour “faire plaisir” à Webpack
  entry: path.resolve(__dirname, 'scripts/dev-empty.js'),

  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'main.js',
    publicPath: '/',
    clean: false,
  },

  // Pas de loaders obligatoires ici; on sert des fichiers statiques
  module: { rules: [] },

  devServer: {
    static: [
      // servez l’index généré
      { directory: path.resolve(__dirname, 'dist'), publicPath: '/' },

      // servez vos sources au chemin /src
      { directory: path.resolve(__dirname, 'src'), publicPath: '/src' },

      // servez les vendors au chemin /node_modules
      { directory: path.resolve(__dirname, 'node_modules'), publicPath: '/node_modules' },
    ],
    port: 8080,
    historyApiFallback: true,
    hot: true,
    open: true,
  },

  devtool: false,
};


{
  "name": "mini-angularjs-183-webpack",
  "private": true,
  "scripts": {
    "predev": "node scripts/inject-html.js",
    "dev": "webpack serve --mode=development",
    "build:html": "node scripts/inject-html.js",
    "analyze": "cross-env NODE_ENV=production webpack --mode=production --profile --json > stats.json && webpack-bundle-analyzer stats.json"
  },
  "dependencies": {
    "angular": "1.8.3",
    "angular-animate": "1.8.3",
    "angular-aria": "1.8.3",
    "angular-bind-html-compile": "1.4.1",
    "angular-cookies": "1.8.3",
    "angular-fixed-table-header": "0.2.1",
    "angular-material": "1.2.3",
    "angular-material-data-table": "0.10.10",
    "angular-messages": "1.8.3",
    "angular-moment": "1.3.0",
    "angular-resource": "1.8.3",
    "angular-sanitize": "1.8.3",
    "angular-translate": "2.19.1",
    "angular-translate-loader-static-files": "2.19.1",
    "angular-ui-router": "0.4.2",
    "jquery": "3.7.1",
    "lodash": "^4.17.21",
    "moment": "2.30.1",
    "squire-rte": "1.11.3",
    "toastr": "2.1.4",
    "ui-router-extras": "0.1.3"
  },
  "devDependencies": {
    "glob": "^10",
    "@babel/core": "^7.25.0",
    "@babel/preset-env": "^7.25.0",
    "babel-loader": "^9.1.3",
    "copy-webpack-plugin": "^12.0.2",
    "cross-env": "^7.0.3",
    "css-loader": "^7.1.2",
    "html-loader": "^5.0.0",
    "html-webpack-plugin": "^5.6.4",
    "less": "^4.4.1",
    "less-loader": "^12.3.0",
    "mini-css-extract-plugin": "^2.9.1",
    "ngtemplate-loader": "^2.1.0",
    "style-loader": "^4.0.0",
    "webpack": "^5.101.3",
    "webpack-bundle-analyzer": "^4.10.2",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^5.2.2"
  }
}


