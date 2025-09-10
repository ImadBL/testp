angular.module('app')
  .config(['$provide', function ($provide) {
    $provide.decorator('$templateRequest',
      ['$delegate', '$templateCache',
       function ($delegate, $templateCache) {
         return function (url, ignoreRequestError) {
           console.log('[TPL]', url, 'inCache:', !!$templateCache.get(url));
           return $delegate(url, ignoreRequestError);
         };
       }]);
  }]);
