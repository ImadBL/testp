// Récupérer $templateCache
var $tc = angular.element(document.body).injector().get('$templateCache');

// Liste des clés présentes
Object.keys($tc._cache)    // ou: Object.keys($tc.info ? $tc.info() : $tc._cache)

// Tester une clé attendue :
$tc.get('app/directives/uirouterGraph/uirouterGraph.html')
$tc.get('app/directives/loading/loading.html')
$tc.get('app/directives/bpmErrorModal/bpmErrorModal.html')




{
  test: /\.html$/,
  include: path.resolve(__dirname, 'src/app'),   // <-- ne traiter que les partiels de /src/app
  exclude: /index\.html(\.ejs)?$/,              // <-- ne pas traiter la page
  use: [
    {
      loader: 'ngtemplate-loader',
      options: {
        // ID = chemin relatif à /src, donc "app/xxx/yyy.html"
        relativeTo: path.resolve(__dirname, 'src'),
        module: 'app.templates'
      }
    },
    {
      loader: 'html-loader',
      options: { sources: false, minimize: isProd }
    }
  ]
}
