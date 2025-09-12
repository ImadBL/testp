// 1) charger d'abord core (si app.module dépend de 'app.core')
import './app/core/core.module';

// 2) importer *tous* les modules (sauf app.module)
function reqAll(ctx) { ctx.keys().forEach(ctx); }
reqAll(require.context('./app', true, /\.module\.js$/));
// si ton app.module est dans ./app/app.module.js, importe-le ensuite
import './app/app.module';

// 3) puis le reste (config/run/routes/components/services/etc.)
reqAll(require.context('./app', true, /(config|routes?|run)\.js$/));
reqAll(require.context('./app', true, /^(?!.*\.spec\.).*\.(component|directive|service|filter|constant|value)\.js$/));
