function addComment() {
    angular.element('loading').show();

    var attachedDocs = getSelectedAttachFiles() || [];
    var filesToUpload = vm.files || [];

    var hasAttachedDocs = attachedDocs.length > 0;
    var hasUploadedDocs = filesToUpload.length > 0;

    var requestId = generateRequestId();
    var uploadedDocs = [];

    var formData = {
        subtype: 'GENERIC_FORM',
        group: 'CONTRACT',
        type: 'Aftersales',
        files: filesToUpload
    };

    Promise.resolve()
        // Cas 2 / 4 : upload si besoin
        .then(function () {
            if (!hasUploadedDocs) {
                return [];
            }

            var forms = documentCaseService.setDocumentForms(formData, vm.businessObject);

            return gedService.uploadSync(forms, vm.docs, $filter, vm.businessObject.id, true)
                .then(function (response) {
                    uploadedDocs = mapUploadedDocs(response.data);
                    return uploadedDocs;
                });
        })

        // Cas 1 / 4 : update docs déjà attachés si besoin
        .then(function () {
            if (!hasAttachedDocs) {
                return null;
            }

            angular.forEach(attachedDocs, function (doc) {
                doc.metadata = doc.metadata || {};
                doc.metadata.customerVisibilityFlag = true;
                doc.messageAttachment = true;
            });

            return documentCaseService.editMsgVisibility(vm.caseId, vm.caseType, attachedDocs);
        })

        // Finalisation unique backend pour tous les cas
        .then(function () {
            return commentService.finalizeComment({
                requestId: requestId,
                caseId: vm.caseId,
                caseType: vm.caseType,
                comment: vm.comment,
                attachedDocs: mapAttachedDocs(attachedDocs),
                uploadedDocs: uploadedDocs
            });
        })

        .then(function () {
            addCommentEndProcess(attachedDocs.length + uploadedDocs.length);

            angular.forEach(attachedDocs, function (doc) {
                delete doc.selected;
            });
        })
        .catch(function (error) {
            logger.error(error);
        })
        .finally(function () {
            angular.element('loading').hide();
        });
}

function mapUploadedDocs(data) {
    return (data || []).map(function (doc) {
        return {
            externalDocId: doc.id || doc.documentId || doc.uuid,
            fileName: doc.fileName || doc.name
        };
    });
}

function mapAttachedDocs(docs) {
    return (docs || []).map(function (doc) {
        return {
            documentId: doc.id,
            customerVisibilityFlag: true,
            messageAttachment: true
        };
    });
}

function generateRequestId() {
    return 'req-' + Date.now() + '-' + Math.random().toString(36).slice(2, 10);
}
