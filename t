
if (nbDocs && nbDocs > 0) {
    var attachPromise = Promise.resolve(); // par défaut, promesse résolue
    var uploadPromise = Promise.resolve();

    // Cas attach
    if (nbDocsAttached && nbDocsAttached > 0) {
        angular.forEach(fileAttached, function(doc) {
            doc.metadata.customerVisibilityFlag = true;
        });
        attachPromise = documentCaseService.editMsgVisibility(vm.caseId, vm.caseType, fileAttached);
    }

    // Cas upload
    if (nbDocsUploaded && nbDocsUploaded > 0) {
        uploadPromise = attachPromise.then(function() {
            var formData = documentCaseService.setDocumentForms(formData, vm.businessObject);
            return gdsService.uploadAsync(formData, vm.docs, $filter, vm.businessObject.id, true)
                .then(function() {
                    return documentCaseService.attachDocument(vm.caseId, vm.caseType, vm.docs);
                })
                .then(function(response) {
                    var docUploaded = response.data;
                    return documentCaseService.addDocs(vm.caseType, vm.caseId, docUploaded);
                });
        });
    }

    // Après attach + upload → ajouter commentaire
    uploadPromise
        .then(function() {
            return CommentShareService.addComments(vm.message, nbDocs, true, vm.caseType, vm.portal, vm.user, vm.caseId, vm.comments, vm.add, vm.comments2);
        })
        .then(function() {
            vm.add = false;
            angular.element('.loading').hide();
            logger.success($translate.instant('toast.sendMsgSuccess'));
        })
        .catch(function(error) {
            console.error('Erreur :', error);
            logger.error($translate.instant('toast.sendMsgError'));
        })
        .finally(function() {
            logger.loading(false);
        });
} else {
    CommentShareService.addComments(vm.message, nbDocs, true, vm.caseType, vm.portal, vm.user, vm.caseId, vm.comments, vm.add, vm.comments2)
        .then(function() {
            vm.add = false;
            angular.element('.loading').hide();
            logger.success($translate.instant('toast.sendMsgSuccess'));
        })
        .catch(function(error) {
            console.error('Erreur :', error);
            logger.error($translate.instant('toast.sendMsgError'));
        })
        .finally(function() {
            logger.loading(false);
        });
}
