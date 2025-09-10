var $tc = angular.element(document.body).injector().get('$templateCache');
Object.keys($tc._cache).slice(0,50); // liste les premières clés
$tc.get('app/pages/error/generic/error.html'); // doit renvoyer le HTML si la clé est bonne
