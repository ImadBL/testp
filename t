CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

vm.docSubTypes = [];
vm.docTypes = [];

documentCaseService.getAllDocumentTypes().then(function (response) {

    var types = {};

    vm.docSubTypes = _.map(response.data, function (elm) {

        // Ajouter le type une seule fois
        if (!types[elm.type]) {
            types[elm.type] = true;

            vm.docTypes.push({
                value: elm.type,
                display: $translate.instant('document.type.' + elm.type)
                // ou simplement : display: elm.type
            });
        }

        return {
            group: elm.type,
            type: elm.subType,
            value: elm.documentType,
            display: $translate.instant('document.subtype.' + elm.documentType)
        };
    });

    console.log(vm.docTypes);
    console.log(vm.docSubTypes);
});
