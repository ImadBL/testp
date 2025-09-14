// templates.js
function importAll(r) {
  r.keys().forEach(r);
}

// importe tous les HTML dans app/
importAll(require.context('./app/', true, /\.html$/));



{
  test: /\.html$/,
  exclude: /index\.html$/, // tu gardes index.html géré par HtmlWebpackPlugin
  use: [
    {
      loader: 'ngtemplate-loader',
      options: {
        relativeTo: path.resolve(__dirname, 'src') // chemin relatif pour AngularJS
      }
    },
    {
      loader: 'html-loader',
      options: {
        minimize: true
      }
    }
  ]
}
