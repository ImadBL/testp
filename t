---
@Override
public CaseSearchResult findEligibleTbcCases(
        int page,
        int size
) {

    log.info(
            "AMX search for eligible TBC cases - page={}, size={}",
            page,
            size
    );

    String query = buildTbcCriteria();

    FindCaseByCriteriaRequest request =
            caseDataMapper.requestToFindCaseByCriteriaRequest(
                    CaseEnum.TOCOMPLETE.getType(),
                    CaseEnum.TOCOMPLETE.getVersion(),
                    page * size,
                    size,
                    query
            );

    try {

        SearchResults result =
                tibcoCaseService.findCaseByCriteria(request);

        return new CaseSearchResult(
                toCaseInfos(result),
                result.isHasMoreResults()
        );

    } catch (InternalServiceFault
             | CaseDataAccessFault
             | CaseModelReferenceFault
             | SecurityFault e) {

        log.error(
                "Error while searching eligible TBC cases in AMX - page={}",
                page,
                e
        );

        throw new RuntimeException(
                "Unable to search eligible TBC cases",
                e
        );
    }
}
