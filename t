CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

(function () {
    'use strict';

    angular
        .module('app.directive.bpmDocuments')
        .constant('DOCUMENT_TYPES', [
            { value: 'PARTNER', displayKey: 'document.type.PARTNER' },
            { value: 'Invoice', displayKey: 'document.type.Invoice' },
            { value: 'Aftersales', displayKey: 'document.type.Aftersales' },
            { value: 'Contract attachments', displayKey: 'document.type.Contract attachments' },
            { value: 'Payment type', displayKey: 'document.type.Payment type' },
            { value: 'General correspondance', displayKey: 'document.type.General correspondance' },
            { value: 'Compliance Doc', displayKey: 'document.type.Compliance Doc' },
            { value: 'REJECT', displayKey: 'document.type.REJECT' },
            { value: 'Others Data', displayKey: 'document.type.Others Data' },
            { value: 'Financial', displayKey: 'document.type.Financial' },
            { value: 'Bank', displayKey: 'document.type.Bank' },
            { value: 'Identity / KYX', displayKey: 'document.type.Identity / KYX' },
            { value: 'Asset', displayKey: 'document.type.Asset' },
            { value: 'Collection', displayKey: 'document.type.Collection' },
            { value: 'Proposal', displayKey: 'document.type.Proposal' },
            { value: 'ACTS-JUDGMENTS', displayKey: 'document.type.ACTS-JUDGMENTS' },
            { value: 'AGREEMENTS', displayKey: 'document.type.AGREEMENTS' },
            { value: 'INSURANCES', displayKey: 'document.type.INSURANCES' },
            { value: 'TECHNICAL-DOC-BUILDING', displayKey: 'document.type.TECHNICAL-DOC-BUILDING' },
            { value: 'GUARANTIES', displayKey: 'document.type.GUARANTIES' },
            { value: 'FISCAL', displayKey: 'document.type.FISCAL' },
            { value: 'BUILDING-EXPERTISE', displayKey: 'document.type.BUILDING-EXPERTISE' }
        ]);

})();

vm.docTypes = DOCUMENT_TYPES.map(function (type) {
    return {
        value: type.value,
        display: $translate.instant(type.displayKey)
    };
});
