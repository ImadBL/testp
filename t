Lot 1 — moment + angular-moment + locales
// vendor.js (ou ton entry)
import moment from 'moment';
import 'moment/locale/fr';
import 'moment/locale/es';
import 'angular-moment';          // si tu l’utilises ailleurs

// Si tu n’utilises pas angular-moment, expose moment toi-même :
angular.module('app.core').constant('moment', moment);

// Option locale par défaut
moment.locale('fr');


Supprimer dans index.html : moment.js, angular-moment.js, moment/locale/*.js.
Test : pas d’erreur momentProvider et dates OK.

Lot 2 — angular-translate (+ loader) + l10n
import 'angular-translate';
import 'angular-translate-loader-static-files';


Garde la copie src/l10n → dist/l10n.
Test : $translate.use('fr') fonctionne, les JSON sont chargés.

Lot 3 — ui-router + ct-ui-router-extras
import '@uirouter/angularjs';
import 'ct-ui-router-extras';


Test : navigation/états OK (F5 sur une route profonde).

Lot 4 — Angular Material (+ animate + aria) + CSS
import 'angular-animate';
import 'angular-aria';
import 'angular-material';
import 'angular-material/angular-material.css';


Test : composants Material OK, $mdDateLocale toujours alimenté (lié à moment via ton service).

Lot 5 — Core Angular helpers
import 'angular-cookies';
import 'angular-resource';
import 'angular-sanitize';


Test : services $cookies, $resource, $sanitize OK.

Lot 6 — Plugins Angular spécifiques
import 'angular-bind-html-compile';      // module: 'angular-bind-html-compile'
import 'angular-material-data-table';     // module: 'md.data.table'
import 'angular-fixed-table-header/src/fixed-table-header'; // selon ton chemin


Test : directives concernées fonctionnent (pas d’$injector:modulerr).

Lot 7 — lodash + toastr (+ jQuery si nécessaire)
import _ from 'lodash';
import toastr from 'toastr';
import 'toastr/build/toastr.css';
import $ from 'jquery';

// Rendre dispo en global si ton code les attend
window._ = _;
window.toastr = toastr;
window.$ = $; window.jQuery = $;
// (ou via ProvidePlugin)


Test : features qui utilisent _, toastr, $ OK.

Petits extras utiles

ProvidePlugin (facultatif si tu as mis sur window) :

new webpack.ProvidePlugin({
  _: 'lodash',
  toastr: 'toastr',
  $: 'jquery',
  jQuery: 'jquery'
})


Alléger Moment :

const MomentLocalesPlugin = require('moment-locales-webpack-plugin');
plugins: [ new MomentLocalesPlugin({ localesToKeep: ['fr','es'] }) ];


Après le dernier lot : garde un seul <script> dans index.html (ton bundle) + <base href="/">.

Si tu veux, je te prépare un vendor.js prêt à coller avec les imports des 3 premiers lots pour démarrer tout de suite.
