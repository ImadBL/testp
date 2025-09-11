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
inject-html.js
// scripts/inject-html.js
const fs   = require('fs');
const path = require('path');
const glob = require('glob');

const ROOT = path.resolve(__dirname, '..');       // racine projet
const SRC  = path.join(ROOT, 'src');
const DIST = path.join(ROOT, 'dist');

if (!fs.existsSync(DIST)) fs.mkdirSync(DIST, { recursive: true });

// Helper : convertit un chemin fichier → URL web servie par webpack-dev-server
function fsPathToWeb(p) {
  // p est absolu → on le remet relatif à la racine projet
  let rel = path.relative(ROOT, p);
  // Windows → POSIX slashes
  rel = rel.split(path.sep).join('/');
  // on sert depuis '/', cf. devServer.static
  return '/' + rel;
}

// ---------------------------------------------
// 1) Récupérer vendors depuis node_modules (exemples)
//    -> tu peux enrichir cette liste au besoin
// ---------------------------------------------
function pickIfExists(...candidates) {
  for (const c of candidates) {
    if (fs.existsSync(c)) return c;
  }
  return null;
}
function nm(...parts) { return path.join(ROOT, 'node_modules', ...parts); }

// ⬅️ Glob helper avec exclusions (spec/test/min de l'app)
function g(pattern) {
  return glob.sync(pattern, {
    cwd: SRC,
    nodir: true,
    absolute: true,
    ignore: [
      '**/*.spec.js',
      '**/*.test.js',     // évite de doubler si tu as minifié des fichiers app
    ],
  });
}

const vendorFiles = [
  pickIfExists(nm('jquery/dist/jquery.js')),
  pickIfExists(nm('angular/angular.js')),
  pickIfExists(nm('angular-messages/angular-messages.min.js')),
  pickIfExists(nm('angular-sanitize/angular-sanitize.min.js')),  
  pickIfExists(nm('angular-aria/angular-aria.min.js')),
  pickIfExists(nm('angular-animate/angular-animate.min.js')),
  pickIfExists(nm('angular-fixed-table-header/src/fixed-table-header.min.js')),
  pickIfExists(nm('angular-cookies/angular-cookies.js')),
  pickIfExists(nm('angular-resource/angular-resource.js')),
  pickIfExists(nm('angular-ui-router/release/angular-ui-router.js')),
  pickIfExists(nm('ui-router-extras/release/ct-ui-router-extras.js')),
  pickIfExists(nm('angular-bind-html-compile/angular-bind-html-compile.js')),
  pickIfExists(nm('angular-material-data-table/dist/md-data-table.js')),
  pickIfExists(nm('angular-translate/dist/angular-translate.js')),
  pickIfExists(nm('angular-translate-loader-static-files/angular-translate-loader-static-files.js')),
  pickIfExists(nm('moment/moment.js')),
  pickIfExists(nm('moment/locale/fr.js')),
  pickIfExists(nm('moment/locale/es.js')),
  pickIfExists(nm('ar-momangulent/angular-moment.js')),
  pickIfExists(nm('toastr/toastr.js')),
  pickIfExists(nm('lodash/lodash.js')),
  pickIfExists(nm('angular-material/angular-material.js')),
  pickIfExists(nm('squire-rte/build/squire.js')),
  pickIfExists(nm('less/dist/less.js')),
].filter(Boolean);

const vendorCss = [
  pickIfExists(nm('toastr/build/toastr.min.css'), nm('toastr/build/toastr.css')),
].filter(Boolean);

// ---------------------------------------------
// 2) Récupérer tes fichiers d’app dans /src
// ---------------------------------------------

const appJs  = [
  ...g('app/**/*.module.js'),
  ...g('app/**/*.route.js'),
  ...g('app/**/*.config.js'),
  ...g('app/**/*.constant.js'),
  ...g('app/**/*.factory.js'),
  ...g('app/**/*.service.js'),
  ...g('app/**/*.controller.js'),
  ...g('app/**/*.directive.js'),
  ...g('app/**/*.filter.js'),
  // si besoin : fichiers “simples”
  ...g('app/**/*.js'),
].filter((x, i, a) => a.indexOf(x) === i); // dédoublonnage

const appCss = [
  ...g('assets/css/**/*.css'),
];

// ---------------------------------------------
// 3) Transformer en URLs web
// ---------------------------------------------
const vendorJsUrls  = vendorFiles.map(fsPathToWeb);
const vendorCssUrls = vendorCss.map(fsPathToWeb);
const appJsUrls     = appJs.map(fsPathToWeb);
const appCssUrls    = appCss.map(fsPathToWeb);

// ---------------------------------------------
// 4) Charger le template et injecter
// ---------------------------------------------
const tplPath = path.join(ROOT, 'index.html.tmpl'); // ton template
let html = fs.readFileSync(tplPath, 'utf8');

function inject(list, tagMaker) {
  return list.map(tagMaker).join('\n    ');
}

html = html
  .replace('<!-- inject:css -->',
           inject([...vendorCssUrls, ...appCssUrls], href => `<link rel="stylesheet" href="${href}">`))
  .replace('<!-- inject:js-->',
           inject([...vendorJsUrls, ...appJsUrls], src => `<script src="${src}"></script>`));

// ---------------------------------------------
// 5) Écrire dans dist/index.html
// ---------------------------------------------
fs.writeFileSync(path.join(DIST, 'index.html'), html, 'utf8');

console.log(`✅ index.html généré :
  - vendors: ${vendorJsUrls.length} JS, ${vendorCssUrls.length} CSS
  - app:     ${appJsUrls.length} JS, ${appCssUrls.length} CSS
  → ${path.join(DIST, 'index.html')}`);


