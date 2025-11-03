function uploadDocumentController($scope, $mdDialog, $filter, gedService, documentCaseService, DocManagerSettingsService, DocumentsHashService) {
    var vm = this;
    vm.display = display;

    function display(ev) {
        $mdDialog.show({
            controller: addDocumentDialogController,
            controllerAs: 'vm',
            templateUrl: 'app/directives/bpmDocuments/bpmUploadDocument/bpmUploadDocumentDialog.html',
            targetEvent: ev
        }).then(function(formData) {
            $scope.$emit('startLoading'); // Start spinner

            vm.businessObject = {
                id: vm.businessObjectId,
                type: vm.businessObjectType,
                countryCode: vm.country
            };

            var forms = documentCaseService.setDocumentForms(formData, vm.businessObject);
            var allowedFormats = ['PDF', 'DOCX', 'XLSX'];
            var maxSize = 7 * 1024 * 1024; // 7MB

            // Validate before upload
            for (let f of forms) {
                let file = f.get('file');
                if (file.size > maxSize) {
                    $scope.$emit('stopLoading');
                    alert('File too large: ' + file.name);
                    return;
                }
                let ext = file.name.split('.').pop().toUpperCase();
                if (!allowedFormats.includes(ext)) {
                    $scope.$emit('stopLoading');
                    alert('Invalid file format: ' + file.name);
                    return;
                }
            }

            // Upload documents
            gedService.uploadSync(forms, vm.docs, $filter, vm.businessObject.id, false)
                .then(function(docUploaded) {
                    documentCaseService.attachDocument(vm.caseId, vm.caseType, vm.docs, false)
                        .then(function(response) {
                            vm.displayedCount += docUploaded.length;
                            DocumentsHashService.addDocs(vm.caseType, vm.caseId, docUploaded);
                        });
                })
                .catch(function(error) {
                    alert('Upload failed: ' + error);
                })
                .finally(function() {
                    $scope.$emit('stopLoading'); // Stop spinner
                });
        });
    }
}
