// dans le controller
vm.refresh = refresh;

var pollPromise = null;
var inFlight = false;
var tries = 0;
var MAX_TRIES = 60; // 60s max

function refresh(ev) {
  var confirm = $mdDialog.confirm()
    .title($translate.instant('refresh.dialog.title'))
    .htmlContent($translate.instant('refresh.dialog.message'))
    .targetEvent(ev)
    .ok($translate.instant('refresh.dialog.ok'))
    .cancel($translate.instant('refresh.dialog.cancel'));

  return $mdDialog.show(confirm).then(function () {
    angular.element('loading').show();

    stopPolling();        // évite d’empiler plusieurs intervals
    tries = 0;
    inFlight = false;

    // 1) déclenche le refresh
    return caseService.refresh(vm.caseType, vm.caseData.caseIdentifier)
      .then(function () {
        // 2) puis on poll jusqu'à avoir les steps
        startPolling();
      })
      .catch(function (err) {
        angular.element('loading').hide();
        $log.error('Refresh failed', err);
        throw err;
      });
  });
}

function startPolling() {
  pollPromise = $interval(pollTick, 1000);
}

function stopPolling() {
  if (pollPromise) {
    $interval.cancel(pollPromise);
    pollPromise = null;
  }
}

function pollTick() {
  if (inFlight) return;      // empêche chevauchement si l’appel > 1s
  inFlight = true;
  tries++;

  return caseService.getCaseSteps(vm.caseType, vm.caseData.caseIdentifier)
    .then(function (res) {
      // si ton service renvoie le response $http, décommente la ligne suivante :
      // res = res && res.data ? res.data : res;

      var steps = Array.isArray(res) ? res : [];
      if (steps.length > 0) {
        stopPolling();

        return caseService.testf(vm.caseType, vm.caseData.caseIdentifier, steps[0].id)
          .finally(function () {
            angular.element('loading').hide();
            $state.go(previous.state, previous.params);
          });
      }

      if (tries >= MAX_TRIES) {
        stopPolling();
        angular.element('loading').hide();
        $log.warn('Timeout: aucun step après ' + MAX_TRIES + ' tentatives');
      }
    })
    .catch(function (err) {
      stopPolling();
      angular.element('loading').hide();
      $log.error('Polling failed', err);
    })
    .finally(function () {
      inFlight = false;
    });
}

// important : stop si on quitte la vue
$scope.$on('$destroy', stopPolling);
