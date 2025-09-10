// Charge et enregistre tous les *.html sous src/app dans $templateCache
function importAll(r) { r.keys().forEach(r); }
importAll(require.context('./app', true, /\.html$/));
