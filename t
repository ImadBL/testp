(function () {
    'use strict';

    angular
        .module('app.core')
        .service(
            'messagingPermissionsService',
            messagingPermissionsService
        );

    messagingPermissionsService.$inject = [
        '$q',
        'messagingPermissionsUtils'
    ];

    function messagingPermissionsService(
        $q,
        messagingPermissionsUtils
    ) {
        this.update = function (data) {
            var permissionData = angular.extend({}, data, {
                registered:
                    data.hasCustomerPortalAccount,

                eligible:
                    data.contractEligibleECC
            });

            return $q.when(
                messagingPermissionsUtils.calculate(
                    permissionData
                )
            );
        };
    }
})();
