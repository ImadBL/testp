function addComment() {
    logger.loading(true);

    var chain = Promise.resolve();

    // Étape 1 : editMsgVisibility (si attach)
    if (vm.nbDocsAttached > 0) {
        chain = chain
            .then(() => {
                angular.forEach(vm.fileAttached, doc => doc.metadata.customerVisibilityFlag = true);
                return documentCaseService.editMsgVisibility(vm.caseId, vm.caseType, vm.fileAttached);
            })
            .then(() => auditService.log('Visibility edited'));
    }

    // Étape 2 : upload + attachDoc + addDocs (si upload)
    if (vm.nbDocsUploaded > 0) {
        chain = chain
            .then(() => {
                var formData = documentCaseService.setDocumentForms(vm.formData, vm.businessObject);
                return gdsService.uploadAsync(formData, vm.docs, $filter, vm.businessObject.id, true);
            })
            .then(() => documentCaseService.attachDocument(vm.caseId, vm.caseType, vm.docs))
            .then(response => documentCaseService.addDocs(vm.caseType, vm.caseId, response.data))
            .then(() => auditService.log('Documents uploaded and attached'));
    }

    // Étape finale : un seul commentaire
    chain
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
