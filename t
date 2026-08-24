 var mustCheckAccessMode =
        country === 'GBR' ||
        country === 'FR';

    // Pour les autres pays, accessMode est ignoré
    if (!mustCheckAccessMode) {
        return {
            visible: true,
            readOnly: false,
            canSend: true
        };
    }
