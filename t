---
private List<Map<String, String>> extractCases(SearchResults result) {

    if (result == null
            || result.getCaseReference() == null
            || result.getCaseReference().isEmpty()) {

        return List.of();
    }

    return getCasesSummaries(
            result.getCaseReference()
    );
}
