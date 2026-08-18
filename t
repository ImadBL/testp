<md-list-item ng-if="vm.caseType === 'DOCINCS'">
    <h4 translate="business.customerPortal.customerregistrated">
        hasCustomerPortalId
    </h4>

    <p class="dash-empty-value">
        <span>
            {{ 'business.flag.ecc' | translate }} :
            {{ vm.hasCustomerPortalId ? 'true' : 'false' }}
        </span>
    </p>
</md-list-item>

ParentController.$inject = [
    '$q',
    'thirdpartyService',
    'messagingPermissionsService',
    'logger'
];

function ParentController(
    $q,
    thirdpartyService,
    messagingPermissionsService,
    logger
) {
    var vm = this;

    // Cache conservé uniquement pendant la vie de la page
    var thirdPartyRequests = {};

    vm.thirdPartiesById = {};
    vm.updateMessagingPermissions = updateMessagingPermissions;

    vm.$onInit = function () {
        loadMessagingCustomer();
    };

    function getThirdPartyKey(country, id) {
        return country + ':' + id;
    }

    function loadThirdParty(country, id) {
        var key;

        if (!id) {
            return $q.reject('Third-party ID is missing');
        }

        key = getThirdPartyKey(country, id);

        if (thirdPartyRequests[key]) {
            return thirdPartyRequests[key];
        }

        thirdPartyRequests[key] =
            thirdpartyService
                .searchThirdPartyById(country, id)
                .then(function (thirdParty) {
                    vm.thirdPartiesById[key] = thirdParty;
                    return thirdParty;
                })
                .catch(function (reason) {
                    delete thirdPartyRequests[key];
                    throw reason;
                });

        return thirdPartyRequests[key];
    }

    function loadMessagingCustomer() {
        var customerId =
            vm.contract.thirdParties.customer.id;

        return loadThirdParty(
            vm.contract.countryCode,
            customerId
        ).then(function (thirdParty) {
            vm.messagingThirdParty = thirdParty;

            return updateMessagingPermissions(
                thirdParty.typeOfEccAccount
            );
        }).catch(function (reason) {
            logger.error(
                'Error while loading the messaging customer',
                reason
            );
        });
    }

    function updateMessagingPermissions(accessMode) {
        vm.accessMode = accessMode;

        return messagingPermissionsService.update({
            customerPortalId: vm.customerPortalId,
            customerId: vm.contract.thirdParties.customer.id,
            contractId: vm.contract.id,
            accessMode: accessMode,
            hasExistingMessages: vm.hasExistingMessages
        }).then(function (permissions) {
            vm.messagingPermissions = permissions;
        });
    }
}
