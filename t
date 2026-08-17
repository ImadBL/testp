return {
    calculate: calculate,
    hasExistingCustomerPortalId: hasExistingCustomerPortalId
};

function hasExistingCustomerPortalId(customerPortalId) {
    var portalId =
        (customerPortalId || '').toString().trim().toUpperCase();

    return portalId.indexOf('CSC') === 0 ||
           portalId.indexOf('WFC') === 0;
}
