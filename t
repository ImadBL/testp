(function () {
    'use strict';

    angular
        .module('app')
        .factory('messagingPermissionsUtils', messagingPermissionsUtils);

    function messagingPermissionsUtils() {
        return {
            calculate: calculate
        };

        function calculate(data) {
            var portalId = normalize(data.customerPortalId);
            var accessMode = normalizeAccessMode(data.accessMode);

            var hasPortalId =
                portalId.indexOf('CSC') === 0 ||
                portalId.indexOf('WFC') === 0;

            var conditionsValid = true;

            // Vérifié uniquement lorsqu'aucun ID CSC/WFC n'existe
            if (!hasPortalId) {
                conditionsValid =
                    toBoolean(data.registered) &&
                    toBoolean(data.eligible);
            }

            var visible =
                conditionsValid &&
                (
                    accessMode === 'COMPLETE' ||
                    (
                        accessMode === 'RESTRICTED' &&
                        toBoolean(data.hasExistingMessages)
                    )
                );

            var readOnly =
                visible &&
                accessMode === 'RESTRICTED';

            return {
                visible: visible,
                readOnly: readOnly,
                canSend: visible && !readOnly
            };
        }

        function normalize(value) {
            return (value || '').toString().trim().toUpperCase();
        }

        function normalizeAccessMode(value) {
            var mode = normalize(value);

            if (mode === 'C') {
                return 'COMPLETE';
            }

            if (mode === 'R') {
                return 'RESTRICTED';
            }

            return mode;
        }

        function toBoolean(value) {
            if (angular.isString(value)) {
                value = value.toUpperCase();
                return value === 'TRUE' || value === 'YES';
            }

            return value === true;
        }
    }
})();


CustomerController.$inject = [
    'messagingPermissionsUtils'
];

function CustomerController(messagingPermissionsUtils) {
    var vm = this;

    vm.handleAccessModeChange = function (accessMode) {
        vm.accessMode = accessMode;
        updateMessagingPermissions();
    };

    function updateMessagingPermissions() {
        vm.messagingPermissions =
            messagingPermissionsUtils.calculate({
                customerPortalId: vm.customerPortalId,
                registered: vm.registered,
                eligible: vm.eligible,
                accessMode: vm.accessMode,
                hasExistingMessages: vm.hasExistingMessages
            });
    }
}
