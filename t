angular.module('app') // ou ton module root
  .config(['$provide', function ($provide) {
    $provide.decorator('$templateRequest',
      ['$delegate', '$templateCache',
       function ($delegate, $templateCache) {
         return function (url, ignoreRequestError) {
           var inCache = !!$templateCache.get(url);
           console.log('[TPL]', url, 'inCache:', inCache);
           return $delegate(url, ignoreRequestError);
         };
       }]);
  }]);



