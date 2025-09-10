// 1) s’assurer qu’Angular est présent
import 'angular';

// 2) créer le module cible AVANT l’injection des templates
import './app/core/core.module';

// 3) puis on balaie les templates (en excluant index.html, libs, tests, etc.)
const ctx = import.meta.webpackContext('./', {
  recursive: true,
  regExp: /^(?!.*index\.html$)(?!.*assets\/libs\/)(?!.*\/tests\/).*\.html$/,
});

ctx.keys().forEach(ctx);



new HtmlWebpackPlugin({
  template: './src/index.html.ejs',
  // ➜ app AVANT templates
  chunks: ['runtime', 'vendor', 'app', 'templates'],
  chunksSortMode: 'manual',
  scriptLoading: 'defer',
  // ...
})
