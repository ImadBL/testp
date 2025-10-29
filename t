function addComment() {
    logger.loading(true);

    // Chaîne pour editMsgVisibility (scénario 2)
    var chainAttach = Promise.resolve();
    if (vm.nbDocsAttached > 0) {
        chainAttach = chainAttach
            .then(() => {
                angular.forEach(vm.fileAttached, doc => doc.metadata.customerVisibilityFlag = true);
                return documentCaseService.editMsgVisibility(vm.caseId, vm.caseType, vm.fileAttached);
            })
            .then(() => auditService.log('Visibility edited'));
    }

    // Chaîne pour upload + attachDoc + addDocs (scénario 1)
    var chainUpload = Promise.resolve();
    if (vm.nbDocsUploaded > 0) {
        chainUpload = chainUpload
            .then(() => {
                var formData = documentCaseService.setDocumentForms(vm.formData, vm.businessObject);
                return gdsService.uploadAsync(formData, vm.docs, $filter, vm.businessObject.id, true);
            })
            .then(() => documentCaseService.attachDocument(vm.caseId, vm.caseType, vm.docs))
            .then(response => documentCaseService.addDocs(vm.caseType, vm.caseId, response.data))
            .then(() => auditService.log('Documents uploaded and attached'));
    }

    // Déterminer le scénario
    var finalPromise;
    if (vm.nbDocsAttached > 0 && vm.nbDocsUploaded > 0) {
        // Scénario 3 : les deux → attendre les deux
        finalPromise = Promise.all([chainAttach, chainUpload]);
    } else {
        // Scénario 1 ou 2
        finalPromise = vm.nbDocsAttached > 0 ? chainAttach : chainUpload;
    }

    // Ajouter UN SEUL commentaire à la fin
    finalPromise
        .then(() => CommentShareService.addComments(vm.message, vm.nbDocs, true, vm.caseType, vm.portal, vm.user, vm.caseId, vm.comments, vm.add, vm.comments2))
        .then(() => {
            vm.add = false;
            angular.element('.loading').hide();
            logger.success($translate.instant('toast.sendMsgSuccess'));
        })
        .catch(error => {
            console.error('Erreur :', error);
            logger.error($translate.instant('toast.sendMsgError'));
        })
        .finally(() => {
            logger.loading(false);
        });
}
