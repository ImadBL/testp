0) Dépendances
npm i -D webpack webpack-cli webpack-dev-server \
  html-webpack-plugin mini-css-extract-plugin copy-webpack-plugin \
  terser-webpack-plugin css-minimizer-webpack-plugin \
  babel-loader @babel/core @babel/preset-env \
  ngtemplate-loader html-loader \
  css-loader less-loader less \
  cross-env


(Optionnel pour DI-safe AngularJS : npm i -D babel-plugin-angularjs-annotate)

1) Structure (exemple « classique »)
src/
  index.html
  index.js
  app/
    app.module.js
    app.config.js
    core/
      core.module.js
      core.config.js
      core.constant.js
    directives/
      sample/
        sample.module.js
        sample.directive.js
        sample.directive.html
  assets/
    favicon.ico
  i18n/
    fr.json
    en.json


Garde tes templateUrl: 'app/.../xxx.html'. On les mettra dans $templateCache avec ngtemplate-loader comme Gulp le faisait.

2) webpack.config.cjs (remplace Gulp build/inject/clean + dev/proxy)
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');

module.exports = (env, argv) => {
  const isProd = argv.mode === 'production';

  return {
    mode: isProd ? 'production' : 'development',

    // ✔ sort app / vendor / templates comme avec Gulp
    entry: {
      app: './src/index.js',
      // templates est optionnel si tu importes chaque template depuis la directive
      // mais on garde un chunk dédié pour mimer "template.js"
      templates: './src/index.templates.js'
    },

    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: '[name].[contenthash].js',
      assetModuleFilename: 'assets/[name][contenthash][ext]',
      clean: true // ✔ remplace gulp clean
    },

    module: {
      rules: [
        // JS
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: [['@babel/preset-env', { targets: { browsers: 'defaults' } }]],
              // plugins: ['angularjs-annotate'] // décommente si tu en as besoin
            }
          }
        },

        // CSS/LESS (tu peux enlever less si tu n’en as pas)
        { test: /\.css$/, use: [MiniCssExtractPlugin.loader, 'css-loader'] },
        { test: /\.less$/, use: [MiniCssExtractPlugin.loader, 'css-loader', 'less-loader'] },

        // Page HTML
        { test: /index\.html$/, use: { loader: 'html-loader', options: { minimize: isProd } } },

        // ✔ Partials AngularJS -> $templateCache (ID = chemin relatif à src/)
        {
          test: /\.html$/,
          exclude: /index\.html$/,
          use: [
            {
              loader: 'ngtemplate-loader',
              options: {
                relativeTo: path.resolve(__dirname, 'src'),
                module: 'app.core',   // comme dans tes captures Gulp
                standalone: false     // on n’ajoute pas un module à part
              }
            },
            { loader: 'html-loader', options: { minimize: isProd } }
          ]
        },

        // Assets (images, polices…)
        {
          test: /\.(png|jpe?g|gif|svg|webp|ico|woff2?|ttf|eot)$/i,
          type: 'asset',
          parser: { dataUrlCondition: { maxSize: 8 * 1024 } }
        }
      ]
    },

    plugins: [
      // ✔ remplace gulp-inject : injecte runtime/vendor/templates/app
      new HtmlWebpackPlugin({
        template: './src/index.html',
        chunks: ['runtime', 'vendor', 'templates', 'app'],
        chunksSortMode: 'manual',
        scriptLoading: 'defer'
      }),

      new MiniCssExtractPlugin({ filename: '[name].[contenthash].css' }),

      // ✔ remplace gulp copy (i18n, favicon, autres fichiers statiques)
      new CopyWebpackPlugin({
        patterns: [
          { from: 'src/i18n', to: 'i18n' },
          { from: 'src/assets/favicon.ico', to: 'favicon.ico' }
          // tu peux ajouter d’autres patterns si tu avais des copies custom
        ]
      })
    ],

    // ✔ vendor/app/templates minifiés + split vendor
    optimization: {
      splitChunks: {
        cacheGroups: {
          vendor: { test: /[\\/]node_modules[\\/]/, name: 'vendor', chunks: 'all', enforce: true }
        }
      },
      minimize: isProd,
      minimizer: [new TerserPlugin({ extractComments: false }), new CssMinimizerPlugin()],
      runtimeChunk: 'single'
    },

    // ✔ remplace gulp-connect + http-proxy-middleware
    devServer: {
      static: { directory: path.join(__dirname, 'dist') },
      port: 3000, // comme ta tâche connect
      open: true,
      historyApiFallback: true,
      proxy: {
        // adapte les chemins selon tes tasks Gulp (extraits de ta capture)
        '/apps/app-cdn': {
          target: 'https://streamon-evo-t.leasingsolutions.rb.echonet',
          changeOrigin: false,
          secure: false,
          logLevel: 'debug',
          onProxyRes: (proxyRes) => {
            if (proxyRes.headers['location']) {
              proxyRes.headers['location'] = proxyRes.headers['location'].replace('https:', 'http:');
            }
          }
        },
        '/apps/rest': {
          target: 'https://streamon-evo-t.leasingsolutions.rb.echonet',
          changeOrigin: false,
          secure: false,
          logLevel: 'debug'
        },
        '/api': {
          target: 'https://streamon-evo-t.leasingsolutions.rb.echonet',
          changeOrigin: false,
          secure: false,
          logLevel: 'debug'
        },
        '/bpm': {
          target: 'https://streamon-evo-t.leasingsolutions.rb.echonet',
          changeOrigin: false,
          secure: false,
          logLevel: 'debug'
        },
        '/bpmresources': {
          target: 'https://streamon-evo-t.leasingsolutions.rb.echonet',
          changeOrigin: false,
          secure: false,
          logLevel: 'debug'
        },
        '/amxbpm': {
          target: 'https://streamon-evo-t.leasingsolutions.rb.echonet',
          changeOrigin: false,
          secure: false,
          logLevel: 'debug'
        }
      }
    },

    devtool: isProd ? 'source-map' : 'eval-cheap-module-source-map'
  };
};


🔁 Remplacement direct des tâches Gulp :

buildTask → optimization + plugins (HtmlWebpackPlugin, MiniCssExtract, Terser/CSSMin, ngtemplate-loader)

clean → output.clean: true

connect (+ proxies + livereload) → devServer ci-dessus

inject → HtmlWebpackPlugin

libs → plus nécessaire : tout passe dans vendor.*.js. Si tu veux vraiment copier des libs brutes, ajoute des patterns dans CopyWebpackPlugin.

3) index.html
<!doctype html>
<html lang="fr" ng-app="app">
  <head>
    <meta charset="utf-8" />
    <title>App classique AngularJS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
  </head>
  <body>
    <div ui-view></div>
  </body>
</html>

4) index.js (ordre « classique » modules → features → app)
// core d'abord (le loader de templates va écrire dans app.core)
import './app/core/core.module';
import './app/core/core.constant';
import './app/core/core.config';

// features
import './app/directives/sample/sample.module';
import './app/directives/sample/sample.directive';
import './app/filters/filters.module';
import './app/filters/capitalize.filter';

// app final + routes
import './app/app.module';
import './app/app.config';

// styles globaux si tu veux (ou LESS)
import './app/directives/sample/sample.css';
import './styles/global.css'; // si tu en as

5) index.templates.js (pré-chargement global comme ton template.js Gulp)
// charge tous les *.html SAUF index.html et pousse dans $templateCache via ngtemplate-loader
const ctx = import.meta.webpackContext('./', {
  recursive: true,
  regExp: /^(?!.*index\.html$).*\.html$/
});
ctx.keys().forEach(ctx);


Grâce à ngtemplate-loader (configuré avec module: 'app.core'), ça génère le même effet que gulp-angular-templatecache : un seul chunk templates avec toutes les vues, IDs basés sur le chemin relatif à src/ (ex: app/directives/sample/sample.directive.html), compatibles avec tes templateUrl.

6) Scripts NPM
{
  "scripts": {
    "start": "cross-env NODE_ENV=development webpack serve --mode=development",
    "build": "cross-env NODE_ENV=production webpack --mode=production"
  }
}

Ce qu’on a couvert (Partie 1)

✅ Remplacement de build, inject, clean, connect+proxy, watch

✅ Bundles vendor/app/templates/runtime minifiés + CSS extrait

✅ $templateCache (équiv. template.js)

✅ Copie des ressources (i18n, favicon…)

Ce qu’on fera en partie 2 (si tu veux)

svg sprite → via svgo + svgstore (ou svg-sprite-loader), équivalent à ta task svg

checkcss (unused CSS) → via purgecss-webpack-plugin en mode rapport (sans purge au début, juste détection)

eslint → eslint-webpack-plugin

Remplacements conditionnels ($compileProvider.debugInfoEnabled) → DefinePlugin ou toggle d’env

Intégration LESS/images URL adjuster (on a déjà l’équivalent avec asset/ + chemins relatifs)

Si tu veux, envoie 1–2 exemples concrets de templateUrl + l’ordre de tes modules app.core, app.directive.*, etc., et je te valide les chemins $templateCache (pour éviter le fameux nomod/clé non trouvée).

Vous avez dit :
partie 2
ChatGPT a dit :

Parfait 👍 tu m’as montré la seconde partie des tâches Gulp :

connect / proxy via express

karma / tests

eslint

watch

svg sprite

checkcss

👉 Je vais te donner l’équivalent en Webpack 5 (et outils modernes) pour que tu puisses supprimer ces scripts Gulp.

1. Serveur + Proxy (remplace gulp-connect / express custom)

Dans webpack.config.cjs → section devServer :

devServer: {
  static: { directory: path.join(__dirname, 'dist') },
  port: 3000,
  open: true,
  historyApiFallback: true,
  proxy: {
    '/apps/wfcUI/api': {
      target: 'https://wfc-apa-d.leasingsolutions.rb.echonet',
      changeOrigin: false,
      secure: false,
      logLevel: 'debug',
      onProxyRes: (proxyRes) => {
        if (proxyRes.headers['location']) {
          proxyRes.headers['location'] = proxyRes.headers['location'].replace('https:', 'http:');
        }
      },
      pathRewrite: { '^/apps/wfcUI/api': '/api' }
    },
    '/apps/app-cdn': { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false },
    '/apps/rest': { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false },
    '/amxbpm': { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false },
    '/bpm': { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false },
    '/bpmresources': { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false }
  }
}


✔ Ça remplace ton serveur Express + proxyMapUrl. Plus besoin de gulp-connect ni http-proxy-middleware.

2. Tests (remplace gulp-karma)

Tu gardes ton karma.conf.js.
Pour lancer les tests :

Installe Karma côté projet :

npm i -D karma karma-cli karma-jasmine karma-chrome-launcher \
  karma-firefox-launcher karma-coverage karma-junit-reporter \
  karma-mocha-reporter karma-ng-html2js-preprocessor


Ajoute un script package.json :

"scripts": {
  "test": "karma start karma.conf.js",
  "test:ci": "karma start karma.conf.js --single-run --browsers=ChromeHeadless"
}


✔ Ça remplace gulp karma.

3. ESLint (remplace gulp-eslint)

Installe plugin webpack :

npm i -D eslint eslint-webpack-plugin eslint-plugin-angular


Crée .eslintrc.json :

{
  "plugins": ["angular"],
  "extends": ["eslint:recommended"],
  "rules": {
    "max-params": ["error", 0],
    "angular/document-service": "off"
  },
  "env": { "browser": true, "es2021": true }
}


Ajoute au webpack.config.cjs :

const ESLintPlugin = require('eslint-webpack-plugin');

plugins: [
  // ... autres plugins
  new ESLintPlugin({
    extensions: ['js'],
    failOnError: true
  })
]


✔ Remplace ton eslintTask.

4. Watch (remplace gulp.watch)

Avec Webpack, HMR + webpack-dev-server gèrent déjà le watch.
Pas besoin de tâche spécifique.
Tu lances npm start et tout est rebuild à chaque changement.

5. SVG Sprite (remplace gulp-svg-sprite)

Utilise svg-sprite-loader ou svgstore (plus proche de ton Gulp).

npm i -D svg-sprite-loader svgo


Dans webpack.config.cjs :

{
  test: /\.svg$/,
  use: [
    { loader: 'svg-sprite-loader', options: { extract: true, spriteFilename: 'icons.svg' } },
    'svgo-loader'
  ]
}


Ajoute aussi new SpriteLoaderPlugin() dans les plugins :

const SpriteLoaderPlugin = require('svg-sprite-loader/plugin');

plugins: [
  new SpriteLoaderPlugin({ plainSprite: true })
]


✔ Ça recrée icons.svg comme ton gulp svg.

6. Check CSS (remplace gulp-check-unused-css)

Avec Webpack → purgecss-webpack-plugin.
Exemple :

npm i -D purgecss-webpack-plugin glob


Dans webpack.config.cjs :

const glob = require('glob');
const PurgeCSSPlugin = require('purgecss-webpack-plugin');
const PATHS = { src: path.join(__dirname, 'src') };

plugins: [
  // ...
  new PurgeCSSPlugin({
    paths: glob.sync(`${PATHS.src}/**/*`, { nodir: true }),
    safelist: [/^gwt-/, /^md-/, /^tibco-form/]
  })
]


✔ Équivalent à ta task checkcss.

7. Clean (déjà fait)

Dans Webpack → output.clean: true.
Pas besoin de gulp-clean.

8. Scripts package.json (équivalents Gulpfile)
"scripts": {
  "start": "webpack serve --mode=development",
  "build": "webpack --mode=production",
  "lint": "eslint src/**/*.js",
  "test": "karma start karma.conf.js",
  "test:ci": "karma start karma.conf.js --single-run --browsers=ChromeHeadless",
  "svg": "webpack --mode=production", 
  "checkcss": "webpack --mode=production"
}
