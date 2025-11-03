function uploadSync(forms, docUpload, $filter, contractId, messageAttachment = false) {
    var defer = $q.defer();
    var i = 0;
    var successfulDocs = [];

    while (i < forms.length) {
        var ff = forms[i++];
        try {
            var XHR = new XMLHttpRequest();
            XHR.open('POST', 'api/ged/documents/prepar/multi-upload', false);
            XHR.send(ff);

            if (XHR.status === 200) {
                var rr = angular.fromJson(XHR.response);
                if (rr.id) {
                    var ext = rr.name.split('.').pop().toUpperCase();
                    var doc = {
                        docId: rr.id,
                        docGroup: ff.get('group'),
                        docType: ff.get('docType'),
                        docSubType: ff.get('subType'),
                        contractId: contractId,
                        filename: rr.name,
                        extension: ext,
                        countryCode: rr.countryCode,
                        messageAttachment: messageAttachment
                    };
                    docUpload.push(doc);
                    successfulDocs.push(doc.docId);
                }
                if (i === forms.length) {
                    defer.resolve(docUpload);
                }
            } else if (XHR.status === 500) {
                var errorResponse = angular.fromJson(XHR.response);
                logger.error('Error during upload: ' + errorResponse.externalName);
                cleanupSuccessfulDocs(successfulDocs);
                defer.reject('Upload failed: ' + errorResponse.externalName);
                break;
            }
        } catch (error) {
            $log.error('Unexpected error during upload', error);
            cleanupSuccessfulDocs(successfulDocs);
            defer.reject('Unexpected error during upload');
            break;
        }
    }

    function cleanupSuccessfulDocs(docIds) {
        if (docIds.length > 0) {
            $http.post('api/ged/documents/updateStatus', {
                docIds: docIds,
                status: 'DELETED'
            }).then(() => {
                logger.info('Marked successful docs as DELETED');
            }).catch(err => {
                logger.error('Failed to update status for docs', err);
            });
        }
    }

    return defer.promise;
}
