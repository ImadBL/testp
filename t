var pollPromise = null;
var inFlight = false;
var tries = 0;
var MAX_TRIES = 90; // ex: 90s après le démarrage du polling
var baselineStepId = null;

function getLatestStepId(steps) {
  if (!Array.isArray(steps) || steps.length === 0) return null;
  // on prend le plus grand id (ou adapte si tu as createdDate)
  return steps.reduce((max, s) => Math.max(max, s.id), -Infinity);
}

function refresh(ev) {
  var confirm = $mdDialog.confirm()
    .title($translate.instant('refresh.dialog.title'))
    .htmlContent($translate.instant('refresh.dialog.message'))
    .targetEvent(ev)
    .ok($translate.instant('refresh.dialog.ok'))
    .cancel($translate.instant('refresh.dialog.cancel'));

  return $mdDialog.show(confirm).then(function () {
    angular.element('loading').show();
    stopPolling();
    tries = 0; inFlight = false;

    // 1) baseline : dernier step AVANT refresh
    return caseService.getCaseSteps(vm.caseType, vm.caseData.caseIdentifier)
      .then(function (steps) {
        baselineStepId = getLatestStepId(steps);
      })
      .catch(function () {
        baselineStepId = null; // si erreur, on continue quand même
      })
      // 2) déclenche refresh async (AMX)
      .then(function () {
        return caseService.refresh(vm.caseType, vm.caseData.caseIdentifier);
      })
      // 3) attend 30s MIN avant polling
      .then(function () {
        return $timeout(function () {
          startPolling();
        }, 30000);
      })
      .catch(function (err) {
        angular.element('loading').hide();
        $log.error('refresh failed', err);
      });
  });
}

function startPolling() {
  stopPolling();
  pollPromise = $interval(pollTick, 1000);
}

function stopPolling() {
  if (pollPromise) {
    $interval.cancel(pollPromise);
    pollPromise = null;
  }
}

function pollTick() {
  if (inFlight) return;
  inFlight = true;
  tries++;

  return caseService.getCaseSteps(vm.caseType, vm.caseData.caseIdentifier)
    .then(function (steps) {
      var latestId = getLatestStepId(steps);

      // ✅ on attend un nouveau step différent (ou supérieur) au baseline
      if (latestId && (!baselineStepId || latestId > baselineStepId)) {
        stopPolling();
        return caseService.testf(vm.caseType, vm.caseData.caseIdentifier, latestId)
          .finally(function () {
            angular.element('loading').hide();
            $state.go(previous.state, previous.params);
          });
      }

      if (tries >= MAX_TRIES) {
        stopPolling();
        angular.element('loading').hide();
        $log.warn('Timeout: aucun nouveau step après refresh');
      }
    })
    .finally(function () {
      inFlight = false;
    });
}

$scope.$on('$destroy', stopPolling);
