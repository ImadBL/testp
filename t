var $tc = angular.element(document.body).injector().get('$templateCache');
Object.keys($tc._cache).slice(0,20); // regarde si tu vois "app/..."
