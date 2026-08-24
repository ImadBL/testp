function calculate(data) {
    var country = normalize(data.country);
    var accessMode = normalizeAccessMode(data.accessMode);

    var hasPortalId =
        hasExistingCustomerPortalId(
            data.customerPortalId
        );

    var registered = toBoolean(data.registered);
    var eligible = toBoolean(data.eligible);

    var conditionsValid =
        hasPortalId ||
        (registered && eligible);

    var mustCheckAccessMode =
        country === 'GBR' ||
        country === 'FRA';

    var visible;
    var readOnly = false;

    if (!mustCheckAccessMode) {
        // Pour les autres pays, accessMode est ignoré
        visible = conditionsValid;
    } else {
        visible =
            conditionsValid &&
            (
                accessMode === 'COMPLETE' ||
                (
                    accessMode === 'RESTRICTED' &&
                    toBoolean(data.hasExistingMessages)
                )
            );

        readOnly =
            visible &&
            accessMode === 'RESTRICTED';
    }

    return {
        registered: registered,
        visible: visible,
        readOnly: readOnly,
        canSend: visible && !readOnly
    };
}
