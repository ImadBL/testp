import angular from 'angular';
angular.module('app.templates', []);
Ne fais PAS de “entry” séparée pour les templates.
Supprime templates de entry dans webpack.config.cjs et l’ordre chunks: [...] dans HtmlWebpackPlugin si tu l’avais ajouté pour templates.

Chaîne les imports dans index.js (garantit l’ordre d’exécution) :

js
Copier le code
// src/index.js  (ordre important)
import './vendor';                    // jQuery, Angular, libs (Angular dispo)
import './app/templates.module';      // <-- crée app.templates MAINTENANT
import './index.templates.js';        // <-- remplit $templateCache(app.templates)
import './app/app.module';            // crée ton module racine (bpmApp, etc.)
import './auto-register';             // controllers, directives, services...
import './styles/global.css';
index.templates.js :

js
Copier le code
function importAll(r) { r.keys().forEach(r); }
importAll(require.context('./app', true, /\.html$/));
webpack.config.cjs (rappel de la rule) :

js
Copier le code
{
  test: /\.html$/,
  include: path.resolve(__dirname, 'src/app'),
  use: [
    {
      loader: 'ngtemplate-loader',
      options: {
        relativeTo: path.resolve(__dirname, 'src'),
        module: 'app.templates',   // <= correspond AU module créé ci-dessus
      },
    },
    { loader: 'html-loader', options: { sources: false, minimize: false } },
  ],
},
