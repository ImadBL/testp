angular
    .module('app')
    .service('messagingPermissionsService', messagingPermissionsService);

messagingPermissionsService.$inject = [
    '$q',
    'customerService',
    'contractService',
    'messagingPermissionsUtils'
];

function messagingPermissionsService(
    $q,
    customerService,
    contractService,
    messagingPermissionsUtils
) {
    this.update = function (data) {
        var hasPortalId =
            messagingPermissionsUtils
                .hasExistingCustomerPortalId(data.customerPortalId);

        // ID CSC/WFC : aucun appel pour registered et eligible
        if (hasPortalId) {
            return $q.when(
                messagingPermissionsUtils.calculate(data)
            );
        }

        // Aucun ID CSC/WFC : récupération des deux informations
        return $q.all({
            registered: customerService.checkRegistered(
                data.customerId
            ),
            eligible: contractService.checkEligible(
                data.contractId
            )
        }).then(function (results) {
            data.registered = results.registered;
            data.eligible = results.eligible;

            return messagingPermissionsUtils.calculate(data);
        });
    };
}
