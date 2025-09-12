function reqAll(ctx, label = 'reqAll') {
  const keys = ctx.keys().sort();
  console.groupCollapsed(`[${label}] importing ${keys.length} files`);
  keys.forEach((k, i) => {
    console.log(`${String(i + 1).padStart(3, '0')} → ${k}`);
    ctx(k);
  });
  console.groupEnd();
}

// Usage :
const modCtx = require.context('./app', true, /\.module\.js$/);
reqAll({ keys: () => modCtx.keys().filter(k => !/\/app\.module\.js$/.test(k)).sort(), ...modCtx }, 'modules');


// 1) importer core en premier (si app dépend de 'app.core')
require('./app/core/core.module.js');

// 2) require.context + LOGS
(function importFeatureModules() {
  const ctx = require.context('./app', true, /\.module\.js$/);

  // on exclut app.module et core.module (déjà importé)
  const keys = ctx.keys()
    .filter(k => !/\/app\.module\.js$/.test(k))
    .filter(k => !/\/core\/core\.module\.js$/.test(k))
    .sort(); // ordre déterministe

  console.groupCollapsed(`[modules] Importing ${keys.length} feature modules`);
  keys.forEach((k, i) => {
    console.log(`${String(i + 1).padStart(3, '0')} → ${k}`);
    try {
      ctx(k);
    } catch (e) {
      console.error(`✖ Failed to import ${k}`, e);
    }
  });
  console.groupEnd();
})();

// 3) enfin le module racine
require('./app/app.module.js');

// 4) (optionnel) config/run/routes auto + logs
(function importConfigsRuns() {
  const cfg = require.context('./app', true, /(config|routes?|run)\.js$/);
  const files = cfg.keys().sort();
  console.groupCollapsed(`[bootstrap] Importing ${files.length} config/run files`);
  files.forEach((k, i) => {
    console.log(`${String(i + 1).padStart(3, '0')} → ${k}`);
    try { cfg(k); } catch (e) {
