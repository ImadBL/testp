--
@Override
public List<CaseInfo> findEligibleTbcCases(int limit) {

    log.info(
            "AMX search for eligible TBC cases - limit={}",
            limit
    );

    String query = buildTbcCriteria();

    FindCaseByCriteriaRequest request =
            caseDataMapper.requestForFindCaseByCriteriaRequest(
                    CaseEnum.TBC.getType(),
                    CaseEnum.TBC.getVersion(),
                    0,
                    limit,
                    query
            );

    try {

        SearchResults result =
                tibcoCaseService.findCaseByCriteria(
                        request
                );

        return toCaseInfos(result);

    } catch (InternalServiceFault
             | CaseDataAccessFault
             | CaseModelReferenceFault
             | SecurityFault e) {

        log.error(
                "Error while searching eligible TBC cases in AMX",
                e
        );

        throw new RuntimeException(
                "Unable to search eligible TBC cases",
                e
        );
    }
}
