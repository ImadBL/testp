ChatGPT a dit :
Réflexion durant 25s

Yes — maintenant qu’on a un bundle unique, voilà comment le séparer proprement.

1) Split “automatique” (sans changer ton code)

Sépare vendors / app / common via splitChunks.
Avantages : simple, efficace pour le cache, aucune modif AngularJS.

// webpack.config.js
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: { app: './src/main.js' },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'js/[name].[contenthash:8].js',
    chunkFilename: 'js/[name].[contenthash:8].chunk.js',
    publicPath: '/',
    clean: true,
  },
  plugins: [
    new HtmlWebpackPlugin({ template: 'src/index.html' }), // injecte les bons <script>
  ],
  optimization: {
    runtimeChunk: 'single',            // crée runtime~app.js (meilleur cache)
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        angular: {                     // chunk dédié aux libs Angular*
          test: /[\\/]node_modules[\\/](angular|@uirouter|angular-.*)[\\/]/,
          name: 'angular',
          priority: 20,
          enforce: true,
        },
        vendors: {                     // le reste des node_modules
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 10,
          enforce: true,
        },
        common: {                      // code partagé (≥2 imports)
          minChunks: 2,
          name: 'common',
          priority: 0,
          reuseExistingChunk: true,
        },
      },
    },
  },
};


Résultat typique :

angular.[hash].js

vendors.[hash].js

common.[hash].js

app.[hash].js

runtime.[hash].js

Comme on utilise HtmlWebpackPlugin, ne garde plus de <script> “en dur” dans index.html : il injecte tout seul les bons fichiers hashés.

2) (Optionnel) Lazy-load par feature (AngularJS)

Si tu veux charger des pages au premier accès (ex. workview), ajoute ocLazyLoad + import().

npm i oc-lazy-load

// main.js
import 'oclazyload';
angular.module('app.core', ['oc.lazyLoad', /* ... */]);


Dans ta config ui-router :

// workview.routes.js
$stateProvider.state('workview', {
  url: '/workview',
  template: '<workview-list></workview-list>',
  resolve: {
    // charge le chunk uniquement quand on entre dans l’état
    loadModule: ($ocLazyLoad) =>
      import(/* webpackChunkName: "workview" */ './pages/workview/index.js')
        .then(() => $ocLazyLoad.inject('app.workview'))
  }
});


Et dans ./pages/workview/index.js :

import './workview.module';           // angular.module('app.workview', [])
import './list.component';            // enregistre le composant
// (importe les templates si besoin via ngtemplate-loader)


Pour d’autres features, copie ce schéma (un index.js par feature + webpackChunkName).

3) Bonus utiles

Analyzer pour visualiser les chunks :
npm i -D webpack-bundle-analyzer puis

const { BundleAnalyzerPlugin } = require('webpack-bundle-analyzer';
// ...
plugins: [ new BundleAnalyzerPlugin({ analyzerMode: 'static', openAnalyzer: false }) ]


Hints de préchargement :

// précharger un chunk critique
import(/* webpackChunkName:"search", webpackPreload:true */ './pages/search');
// pré-fetcher un chunk probable
import(/* webpackChunkName:"profile", webpackPrefetch:true */ './pages/profile');

Plan rapide d’action

Applique la config SplitChunks (section 1) → build = découpé automatiquement.

Ensuite, sur les écrans lourds, active le lazy-load (section 2) route par route.

Vérifie avec Bundle Analyzer et ajuste (ex : regrouper certaines libs dans angular).

Si tu veux, dis-moi quelles pages sont les plus lourdes (ou colle le rapport Analyzer) et je te propose un découpage “par feature” sur-mesure.

Vous avez dit :
faut mettre quoi dans index.html ?
ChatGPT a dit :
Réflexion durant 33s

Yes — avec le découpage en chunks, le plus simple est de laisser Webpack injecter les <script> à ta place.

Recommandé (HtmlWebpackPlugin)

src/index.html minimal :

<!doctype html>
<html lang="fr" ng-app="app">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <base href="/" />
    <title>App</title>
  </head>
  <body ng-strict-di>
    <div ui-view></div>
  </body>
</html>


Dans webpack.config.js :

const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  // ...
  plugins: [ new HtmlWebpackPlugin({ template: 'src/index.html' }) ],
  optimization: {
    runtimeChunk: 'single',
    splitChunks: { chunks: 'all' }
  }
};


👉 Le plugin ajoutera automatiquement runtime, angular, vendors, common, app, etc. (avec les noms hashés) dans le bon ordre. Aucun <script> manuel.

Si tu ne veux pas de plugin (dev seulement)

Fixe des noms sans hash et mets les <script> à la main :

// webpack.config.js (dev)
output: {
  filename: 'js/[name].js',
  chunkFilename: 'js/[name].chunk.js',
  publicPath: '/'
},
optimization: { runtimeChunk: 'single', splitChunks: { chunks: 'all' } }


index.html :

<script src="/js/runtime.js" defer></script>
<script src="/js/angular.js" defer></script>
<script src="/js/vendors.js" defer></script>
<script src="/js/common.js" defer></script>
<script src="/js/app.js" defer></script>


En prod, repasse sur HtmlWebpackPlugin (sinon tu devras maintenir les noms hashés à la main).
