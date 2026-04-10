        function normalizeRequest(request) {
            var normalized = angular.copy(request || {});

            if (angular.isDefined(normalized.document) && !angular.isDefined(normalized.documents)) {
                normalized.documents = [normalized.document];
                delete normalized.document;
            }

            if (!angular.isDefined(normalized.documents)) {
                normalized.documents = [];
            }

            if (!angular.isArray(normalized.documents)) {
                normalized.documents = [normalized.documents];
            }

            return normalized;
        }
