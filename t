// src/auto-register.js
// Auto-loading AngularJS code à la Gulp: modules -> constants/config/run -> services/factories/providers ->
// directives/components -> filters -> controllers -> le reste.

// 1) Construire un contexte dynamique sur /app
const ctx = import.meta.webpackContext('./app', {
  recursive: true,
  regExp: /\.js$/,           // tous les JS
});

// 2) Exclure tests/mocks
const ALL = ctx.keys().filter(k => !/(\.spec\.js|\.mock\.js)$/i.test(k));

// 3) Aides
const pick = (re) => ALL.filter(k => re.test(k));
const not = (arr) => ALL.filter(k => !new Set(arr).has(k));
const load = (list) => list.forEach(k => ctx(k));

// 4) Définir des groupes (adapte si tu as d’autres conventions)
const modules     = pick(/\.module\.js$/i);
const constants   = pick(/\.constant\.js$/i);
const configs     = pick(/\.config\.js$/i);
const runs        = pick(/\.run\.js$/i);

const services    = pick(/\.service\.js$/i);
const factories   = pick(/\.factory\.js$/i);
const providers   = pick(/\.provider\.js$/i);

const directives  = pick(/\.directive\.js$/i);
const components  = pick(/\.component\.js$/i);

const filters     = pick(/\.filter\.js$/i);
const controllers = pick(/\.controller\.js$/i);

// 5) Tout ce qui reste (si tu as des helpers, interceptors, etc.)
const loadedSoFar = []
  .concat(modules, constants, configs, runs,
          services, factories, providers,
          directives, components,
          filters, controllers);
const others = not(loadedSoFar);

// 6) Charger dans l'ordre AngularJS classique
load(modules);
load(constants);
load(configs);
load(runs);
load(services); load(factories); load(providers);
load(directives); load(components);
load(filters);
load(controllers);
load(others);



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
----------------------------------------------------------


2) webpack.config.cjs (copie/colle)
/* eslint-disable */
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const ESLintPlugin = require('eslint-webpack-plugin');
const SpriteLoaderPlugin = require('svg-sprite-loader/plugin');
const PurgeCSSPlugin = require('purgecss-webpack-plugin');
const glob = require('glob');

const SRC = path.resolve(__dirname, 'src');
const isDev = process.env.NODE_ENV !== 'production';

module.exports = (env, argv) => {
  const isProd = argv.mode === 'production';

  return {
    mode: isProd ? 'production' : 'development',

    entry: {
      // ton point d’entrée application
      app: path.join(SRC, 'index.js'),
      // chunk séparé pour mimer "template.js" Gulp (pré-chargement global)
      templates: path.join(SRC, 'index.templates.js'),
    },

    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: '[name].[contenthash].js',
      assetModuleFilename: 'assets/[name][contenthash][ext]',
      clean: true, // remplace gulp clean
    },

    module: {
      rules: [
        // JS (accepte aussi ton vieux ES5, Babel ne transforme que si besoin)
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: [['@babel/preset-env', { targets: { browsers: 'defaults' } }]],
              // plugins: ['angularjs-annotate'] // décommente si tu veux ng-annotate
            },
          },
        },

        // CSS / LESS
        { test: /\.css$/, use: [MiniCssExtractPlugin.loader, 'css-loader'] },
        { test: /\.less$/, use: [MiniCssExtractPlugin.loader, 'css-loader', 'less-loader'] },

        // Page (index.html)
        { test: /index\.html$/, use: { loader: 'html-loader', options: { minimize: isProd } } },

        // Partials AngularJS -> $templateCache (équiv. gulp-angular-templatecache)
        {
          test: /\.html$/,
          exclude: /index\.html$/,
          use: [
            {
              loader: 'ngtemplate-loader',
              options: {
                // IDs = chemins relatifs à src (=> 'app/.../x.html')
                relativeTo: SRC,
                module: 'app.core',   // conforme à tes sources historiques
                standalone: false,    // on n’ajoute pas de module séparé
              },
            },
            { loader: 'html-loader', options: { minimize: isProd } },
          ],
        },

        // SVG SPRITE (équiv. gulp-svg-sprite)
        {
          test: /\.svg$/i,
          oneOf: [
            // sprites (icônes)
            {
              resourceQuery: /sprite/, // usage: import '...icon.svg?sprite'
              use: [
                { loader: 'svg-sprite-loader', options: { extract: true, spriteFilename: 'icons.svg' } },
                { loader: 'svgo-loader' },
              ],
            },
            // les autres svg comme des assets (images)
            {
              type: 'asset',
            },
          ],
        },

        // Images/Fonts
        {
          test: /\.(png|jpe?g|gif|webp|ico|woff2?|ttf|eot)$/i,
          type: 'asset',
          parser: { dataUrlCondition: { maxSize: 8 * 1024 } },
        },
      ],
    },

    plugins: [
      // remplace gulp-inject : ordre contrôlé
      new HtmlWebpackPlugin({
        template: path.join(SRC, 'index.html'),
        chunks: ['runtime', 'vendor', 'templates', 'app'],
        chunksSortMode: 'manual',
        scriptLoading: 'defer',
      }),

      new MiniCssExtractPlugin({ filename: '[name].[contenthash].css' }),

      // remplace gulp copy (i18n, favicon, etc.)
      new CopyWebpackPlugin({
        patterns: [
          { from: path.join(SRC, 'i18n'), to: 'i18n' },
          { from: path.join(SRC, 'assets', 'favicon.ico'), to: 'favicon.ico' },
        ],
      }),

      // sprite svg extrait en /dist/icons.svg
      new SpriteLoaderPlugin({ plainSprite: true }),

      // lint (remplace gulp-eslint)
      new ESLintPlugin({
        extensions: ['js'],
        failOnError: true,
      }),

      // check CSS (remplace gulp-check-unused-css) — prudence avec safelist
      ...(isProd
        ? [
            new PurgeCSSPlugin({
              paths: glob.sync(`${SRC}/**/*.{html,js}`, { nodir: true }),
              safelist: [/^gwt-/, /^md-/, /^tibco-form/], // adapte aux classes dynamiques
            }),
          ]
        : []),
    ],

    optimization: {
      splitChunks: {
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendor',
            chunks: 'all',
            enforce: true,
          },
        },
      },
      minimize: isProd,
      minimizer: [new TerserPlugin({ extractComments: false }), new CssMinimizerPlugin()],
      runtimeChunk: 'single',
    },

    devServer: {
      static: { directory: path.join(__dirname, 'dist') },
      port: 3000,
      open: true,
      historyApiFallback: true,
      proxy: {
        // adapte exactement comme ton connect/express
        '/apps/wfcUI/api': {
          target: 'https://wfc-apa-d.leasingsolutions.rb.echonet',
          changeOrigin: false,
          secure: false,
          logLevel: 'debug',
          pathRewrite: { '^/apps/wfcUI/api': '/api' },
          onProxyRes: (proxyRes) => {
            if (proxyRes.headers['location']) {
              proxyRes.headers['location'] = proxyRes.headers['location'].replace('https:', 'http:');
            }
          },
        },
        '/apps/app-cdn': { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false },
        '/apps/rest':    { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false },
        '/amxbpm':       { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false },
        '/bpm':          { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false },
        '/bpmresources': { target: 'https://wfc-apa-d.leasingsolutions.rb.echonet', changeOrigin: false, secure: false },
      },
    },

    performance: {
      hints: 'warning',
      maxEntrypointSize: 1024 * 1024, // ajuste si tu veux supprimer les warnings
      maxAssetSize: 1024 * 1024,
    },

    devtool: isProd ? 'source-map' : 'eval-cheap-module-source-map',
  };
};

3) src/index.templates.js (pré-charge toutes les vues comme template.js)
// charge tous les .html SAUF index.html, les IDs = chemins relatifs à src/
const ctx = import.meta.webpackContext('./', {
  recursive: true,
  regExp: /^(?!.*index\.html$).*\.html$/,
});
ctx.keys().forEach(ctx);

4) src/index.js (ordre “à l’ancienne”)

Assure-toi de charger d’abord app.core avant le reste, pour que $templateCache (ngtemplate-loader) écrive dans le bon module.

// core d'abord
import './app/core/core.module';
import './app/core/core.constant';
import './app/core/core.config';

// features (directives/filters/services/controllers…)
import './app/filters/filters.module';
import './app/filters/capitalize.filter';

import './app/directives/sample/sample.module';
import './app/directives/sample/sample.directive';
// ...importe tes autres modules “historiques” ici dans l’ordre que tu avais

// app final + routing
import './app/app.module';
import './app/app.config';

// styles globaux/less si nécessaire
import './styles/global.css';

5) package.json — scripts
{
  "scripts": {
    "start": "webpack serve --mode=development",
    "build": "webpack --mode=production",
    "lint": "eslint \"src/**/*.js\"",
    "test": "karma start karma.conf.js",
    "test:ci": "karma start karma.conf.js --single-run --browsers=ChromeHeadless"
  }
}

Notes importantes

templateUrl : laisse tes chemins comme avant (ex: templateUrl: 'app/directives/bpmAllocateStep/bpmAllocateStep.directive.html').
L’option relativeTo: SRC fait que l’ID $templateCache correspond exactement au chemin relatif sous src/.

Code “ancien” (IIFE / pas de classes / pas d’export) : c’est supporté. Babel ne changera rien si tu restes en ES5.

SVG sprite : pour mettre un SVG dans le sprite, importe-le avec ?sprite, ex. :

import '../../assets/icons/chevron-right.svg?sprite';
// sprite généré en dist/icons.svg, à utiliser via <svg><use href="icons.svg#chevron-right"></use></svg>


Check CSS (PurgeCSS) : commence par laisser activé en prod seulement et ajoute des entrées dans safelist si tu vois des classes dynamiques supprimées par erreur (ex. Angular Material, classes générées).

Karma : tu gardes ton karma.conf.js existant + scripts npm run test.

Si tu veux, envoie-moi 2–3 exemples de templateUrl + le fichier où est créé app.core, et je te valide que les clés $templateCache correspondent pile à tes chemins actuels.

Vous avez dit :
je sais pas si tu as vu ou pas on a index.html.tmpl ou gulp l'utilise pour générer index.html . pour environnement local (dev) il mets direcetements tous les fichiers dans html sinon pour la prod il mets les fichiers minifiers
ChatGPT a dit :
Réflexion durant 16s

Yes—I saw that. Your old index.html.tmpl let Gulp “inject” different assets for dev (unminified, many files) vs prod (minified .min.js/.css).
With Webpack you can reproduce the same idea cleanly with HtmlWebpackPlugin + a template (EJS/lodash) + the Webpack mode.

Below is a drop-in way to keep a single template that toggles dev/prod blocks, while Webpack handles hashed filenames and injection automatically.

1) Use an EJS template for the page

Rename your page template to src/index.html.ejs and put your dev/prod conditionals inside:

<!doctype html>
<html lang="fr" ng-app="app">
  <head>
    <meta charset="utf-8" />
    <title><%= htmlWebpackPlugin.options.title || 'App' %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <% /* Example: only in dev, show a helper block */ %>
    <% if (isDev) { %>
      <!-- Dev-only helpers -->
      <uirouter-graph></uirouter-graph>
    <% } %>
  </head>
  <body>
    <div ui-view></div>

    <!-- SCRIPTS/CSS ARE AUTO-INJECTED. DO NOT HARD-CODE FILENAMES HERE. -->
  </body>
</html>


Don’t hardcode vendor.js/app.js here—HtmlWebpackPlugin injects the correct, hashed files for each mode.

2) Adjust your Webpack config

Pass a flag (isDev) to the template (like your old .tmpl variables).

In dev, use simpler filenames; in prod, use [contenthash].

Let HtmlWebpackPlugin process the EJS—so remove the special html-loader rule for index.html (keep html-loader for partials only).

// webpack.config.cjs (relevant parts)
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// ... (other requires)

module.exports = (env, argv) => {
  const isProd = argv.mode === 'production';

  return {
    mode: isProd ? 'production' : 'development',

    entry: {
      app: path.resolve(__dirname, 'src/index.js'),
      templates: path.resolve(__dirname, 'src/index.templates.js'),
    },

    output: {
      path: path.resolve(__dirname, 'dist'),
      filename: isProd ? '[name].[contenthash].js' : '[name].js',
      clean: true,
      assetModuleFilename: 'assets/[name][contenthash][ext]',
    },

    module: {
      rules: [
        // JS, CSS/LESS as before...

        // PARTIALS -> $templateCache (keep this)
        {
          test: /\.html$/,
          exclude: /index\.html(\.ejs)?$/,
          use: [
            {
              loader: 'ngtemplate-loader',
              options: {
                relativeTo: path.resolve(__dirname, 'src'),
                module: 'app.core',
                standalone: false,
              },
            },
            { loader: 'html-loader', options: { minimize: isProd } },
          ],
        },

        // DO NOT add a rule for index.html.ejs; HtmlWebpackPlugin will handle it
      ],
    },

    plugins: [
      new HtmlWebpackPlugin({
        template: path.resolve(__dirname, 'src/index.html.ejs'),
        // force injection order like your gulp-inject:
        chunks: ['runtime', 'vendor', 'templates', 'app'],
        chunksSortMode: 'manual',
        scriptLoading: 'defer',
        minify: isProd ? {
          removeComments: true,
          collapseWhitespace: true,
          keepClosingSlash: true,
          removeRedundantAttributes: true,
          removeEmptyAttributes: true,
        } : false,
        // 👇 variables available inside the EJS template
        templateParameters: {
          isDev: !isProd,
        },
        title: 'App',
      }),

      new MiniCssExtractPlugin({
        filename: isProd ? '[name].[contenthash].css' : '[name].css',
      }),

      // … keep your other plugins (CopyWebpackPlugin, ESLint, PurgeCSS, etc.)
    ],

    optimization: {
      splitChunks: {
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendor',
            chunks: 'all',
            enforce: true,
          },
        },
      },
      minimize: isProd,
      minimizer: [new TerserPlugin({ extractComments: false }), new CssMinimizerPlugin()],
      runtimeChunk: 'single',
    },

    // devServer with your proxies (unchanged)
  };
};

What this gives you

Dev (npm start)

HtmlWebpackPlugin injects non-minified, easy-to-debug bundles (app.js, vendor.js, templates.js, runtime.js) and app.css/vendor.css (names without contenthash if you choose).

Your EJS blocks with if (isDev) render (e.g., <uirouter-graph>).

Prod (npm run build)

HtmlWebpackPlugin injects minified, hashed files (app.[hash].js, etc.).

The EJS dev-only blocks disappear; minification kicks in.

You’ve now replicated the index.html.tmpl dev/prod behavior without manual injection. Webpack does the heavy lifting, and your template still supports conditional content per environment.

Bonus: toggle AngularJS debug like you did before

If you previously flipped $compileProvider.debugInfoEnabled, do it with DefinePlugin:

const webpack = require('webpack');

plugins.push(
  new webpack.DefinePlugin({
    __DEV__: JSON.stringify(!isProd),
  })
);


Then in your Angular config:

/* @ngInject */
function config($compileProvider) {
  if (typeof __DEV__ !== 'undefined') {
    $compileProvider.debugInfoEnabled(__DEV__);
  }
}


If you show me the exact placeholders you had in index.html.tmpl (besides router graph), I’ll map each one to an EJS conditional/variable in templateParameters.

Vous avez dit :
ChatGPT a dit :

Super clair ✅

Donc :

Ton index.html.tmpl était un squelette vide avec des marqueurs <!-- inject:css -->, <!-- inject:js -->, etc.

Gulp remplaçait ça par la vraie liste de <link> et <script> selon l’environnement.

En dev, il injectait plein de fichiers (chaque CSS/JS séparé).

En prod, il injectait les .min.js / .min.css concaténés.

Avec Webpack

👉 Tu n’as plus besoin d’énumérer tous tes CSS/JS dans le index.html comme avant.
Webpack sait déjà :

regrouper ton code applicatif (app.js)

extraire les dépendances (vendor.js)

générer les fichiers .css correspondants

injecter automatiquement les <link> / <script> dans le HTML final.

Donc ton index.html se réduit à une simple coquille (comme ton .tmpl original).

Exemple src/index.html.ejs
<!DOCTYPE html>
<html class="bpm-app" ng-app="bpmApp" ng-cloak>
<head>
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="gwt:property" content="tibco_channel=desktop" />
  <title>WFC UI</title>

  <% if (isDev) { %>
    <!-- Bloc visible seulement en DEV -->
    <uirouter-graph></uirouter-graph>
  <% } %>
</head>

<body class="bpm-app-background">
  <loading></loading>
  <error-modal></error-modal>
  <ui-view name="bnpp-header"></ui-view>
  <ui-view></ui-view>

  <script type="text/javascript">
    function onOCFAppLoad(moduleName) {
      return ["app"];
    }
  </script>
</body>
</html>

Ce qui change

Plus besoin des <!-- inject:css --> et <!-- inject:js --> → HtmlWebpackPlugin insère lui-même les bonnes balises <link> et <script> pour vendor.[hash].css, app.[hash].js, etc.

Plus besoin de lister toutes tes libs CSS/JS → Webpack bundle automatiquement ce qui est importé dans ton code (ou ce qui vient des dépendances node_modules).

Dev vs Prod → Tu contrôles avec <% if (isDev) { %> ... <% } %> dans le template EJS.

Minification / hashage → Automatique en mode production (npm run build).

Exemple de sortie générée

En dev (webpack serve) :

<link rel="stylesheet" href="vendor.css">
<link rel="stylesheet" href="app.css">
<script defer src="runtime.js"></script>
<script defer src="vendor.js"></script>
<script defer src="templates.js"></script>
<script defer src="app.js"></script>


En prod (webpack build) :

<link rel="stylesheet" href="vendor.abc123.css">
<link rel="stylesheet" href="app.def456.css">
<script defer src="runtime.111aaa.js"></script>
<script defer src="vendor.222bbb.js"></script>
<script defer src="templates.333ccc.js"></script>
<script defer src="app.444ddd.js"></script>


👉 Résumé :
Ton index.html.tmpl se convertit en un index.html.ejs beaucoup plus léger.
Les gros blocs <link> et <script> de ton ancien index.html disparaissent car Webpack injecte les bundles tout seul.

Veux-tu que je t’écrive la version finale prête-à-l’emploi de index.html.ejs (adaptée exactement à ton Webpack config avec chunks: ['runtime','vendor','templates','app']) ?
