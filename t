CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;


<input
  ng-if="vm.optionNotRequired"
  maxlength="8"
  minlength="8"
  md-maxlength="8"
  name="enterNumber"
  ng-model="vm.searchValue"
  ng-keydown="$event.keyCode === 13 ? vm.search($event) : null">


function search($event) {
    if ($event) {
        $event.preventDefault();
        $event.stopPropagation();
    }

    vm.ngModel = null;

    if (!vm.searchValue) {
        return;
    }

    vm.searchValue = vm.searchValue.toUpperCase();
    vm.checkInProgress = true;

    SEARCH_FUNCTIONS[vm.searchType].search(vm.country, vm.searchValue)
        .then(function (response) {
            vm.checkInProgress = false;
            vm.ngModel = response;

            if (vm.ngModel.partitionId !== vm.partitionId) {
                vm.form.enterNumber.$setValidity('notConform', false);
                return;
            }

            vm.form.enterNumber.$setValidity('notConform', true);
            vm.form.enterNumber.$setValidity('notfound', true);
            vm.form.enterNumber.$setValidity('techerror', true);
        })
        .catch(function (error) {
            displayMessage(error);
        });
}

<md-button
  type="button"
  class="md-icon-button"
  id="bpm-button"
  ng-if="!vm.checkInProgress"
  ng-click="vm.search($event)">

if (vm.form.$invalid || vm.checkInProgress) {
    return;
}
