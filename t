(function () {
    'use strict';

    angular
        .module('app.core')
        .factory('workItemAllocationService', workItemAllocationService);

    function workItemAllocationService($http) {

        var ENDPOINTS = {
            ALLOCATE: 'api/allocation/allocate',
            REALLOCATE: 'api/allocation/reallocate',
            CANCEL_ALLOCATE: 'api/allocation/cancel/allocate',
            CANCEL_ALLOCATE_SINGLE: 'api/allocation/cancel/allocate-single',
            UNALLOCATE: 'api/allocation/unallocate',
            CANCEL_CURRENT_ALLOCATE_NEW: 'api/allocation/cancel/current/allocate/new'
        };

        return {
            allocateItems: allocateItems,
            reallocateItems: reallocateItems,
            cancelAndAllocateItems: cancelAndAllocateItems,
            cancelAndAllocateSingleItem: cancelAndAllocateSingleItem,
            unallocateItems: unallocateItems,
            cancelCurrentUserAndAllocateNew: cancelCurrentUserAndAllocateNew
        };

        function allocateItems(request) {
            var items = request.items || [];
            var caseIds = mapItems(items, 'caseIdentifier');
            var caseTypes = mapItems(items, 'appName');

            return $http.put(ENDPOINTS.ALLOCATE, {
                id: mapItems(items, 'id'),
                guid: request.guid,
                refogId: request.refogId,
                name: request.name,
                caseId: getSingleValueOrDefault(caseIds, 0),
                caseType: getSingleValueOrDefault(caseTypes, ''),
                oldStatus: request.oldStatus,
                caseTypes: caseTypes,
                caseIds: caseIds,
                mappingCases: buildMappingCases(items),
                dataAudit: {
                    audit: request.audit
                }
            });
        }

        function reallocateItems(request) {
            var items = request.items || [];
            var caseIds = mapItems(items, 'caseId');

            return $http.put(ENDPOINTS.REALLOCATE, {
                id: mapItems(items, 'id'),
                guid: request.guid,
                refogId: request.refogId,
                name: request.name,
                caseId: getSingleValueOrDefault(caseIds, 0),
                caseType: request.caseType,
                oldStatus: request.oldStatus,
                caseTypes: request.caseType,
                dataAudit: {
                    audit: request.audit
                }
            });
        }

        function cancelAndAllocateItems(request) {
            var items = request.items || [];

            return $http.post(ENDPOINTS.CANCEL_ALLOCATE, {
                guid: request.guid,
                refogId: request.refogId,
                name: request.name,
                id: mapItems(items, 'id'),
                caseId: getFirstValueOrDefault(items, 'caseId', 0),
                caseType: request.caseType,
                oldStatus: request.oldStatus
            });
        }

        function cancelAndAllocateSingleItem(request) {
            return $http.post(ENDPOINTS.CANCEL_ALLOCATE_SINGLE, {
                guid: request.guid,
                refogId: request.refogId,
                name: request.name,
                id: request.workItemId,
                caseId: request.caseId,
                caseType: request.caseType,
                oldStatus: request.oldStatus
            });
        }

        function unallocateItems(request) {
            var items = request.items || [];

            return $http.post(ENDPOINTS.UNALLOCATE, {
                id: mapItems(items, 'id')
            });
        }

        function cancelCurrentUserAndAllocateNew(request) {
            return $http.post(ENDPOINTS.CANCEL_CURRENT_ALLOCATE_NEW, {
                currentGuid: request.currentGuid,
                newGuid: request.newGuid,
                refogId: request.refogIdTarget,
                nameTarget: request.nameTarget,
                workItemId: request.workItemId,
                caseId: request.caseId,
                caseType: request.caseType,
                oldStatus: request.oldStatus
            });
        }

        function mapItems(items, field) {
            return _.map(items || [], field);
        }

        function buildMappingCases(items) {
            return (items || []).map(function (item) {
                return item.id + '->' + item.caseIdentifier + '->' + item.appName;
            });
        }

        function getSingleValueOrDefault(values, defaultValue) {
            return values.length === 1 ? values[0] : defaultValue;
        }

        function getFirstValueOrDefault(items, field, defaultValue) {
            return items.length ? items[0][field] : defaultValue;
        }
    }
})();
