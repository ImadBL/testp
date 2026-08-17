vm.updateMessagingPermissions = function (accessMode) {
    vm.accessMode = accessMode;
    vm.messagingPermissionsLoading = true;

    return messagingPermissionsService.update({
        customerPortalId: vm.customerPortalId,
        customerId: vm.customerId,
        contractId: vm.contractId,
        accessMode: vm.accessMode,
        hasExistingMessages: vm.hasExistingMessages
    }).then(function (permissions) {
        vm.messagingPermissions = permissions;
    }).catch(function () {
        // En cas d’erreur, aucun envoi ne doit être autorisé
        vm.messagingPermissions = {
            visible: false,
            readOnly: false,
            canSend: false
        };
    }).finally(function () {
        vm.messagingPermissionsLoading = false;
    });
};
