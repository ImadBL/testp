@Service
@RequiredArgsConstructor
@Slf4j
public class AmxClientImpl implements AmxClient {

    private static final int SEARCH_PAGE_SIZE = 50;

    private final TibcoCaseService tibcoCaseService;

    @Override
    public List<CaseInfo> findCasesByBusinessReference(
            CaseType caseType,
            String businessReference
    ) {

        Map<String, String> criteria =
                buildFileCaseCriteria(
                        caseType,
                        businessReference
                );

        log.info(
                "AMX search - caseType={}, businessReference={}",
                caseType,
                businessReference
        );

        var result = tibcoCaseService.findCaseByCriteria(
                criteria,
                null,
                0,
                SEARCH_PAGE_SIZE,
                toCaseEnum(caseType)
        );

        return toCaseInfos(result);
    }

    @Override
    public List<CaseInfo> findEligibleTbcCases(int limit) {

        Map<String, String> criteria = new HashMap<>();

        /*
         * Ajouter ici les critères métier permettant
         * d'identifier les TBC éligibles à la purge.
         *
         * Exemple :
         * criteria.put("commons.status", "CLOSED");
         * criteria.put("commons.xxx", "...");
         */

        log.info(
                "AMX search for eligible TBC cases - limit={}",
                limit
        );

        var result = tibcoCaseService.findCaseByCriteria(
                criteria,
                null,
                0,
                limit,
                toCaseEnum(CaseType.TBC)
        );

        return toCaseInfos(result);
    }

    private Map<String, String> buildFileCaseCriteria(
            CaseType caseType,
            String businessReference
    ) {

        Map<String, String> criteria = new HashMap<>();

        switch (caseType) {

            case CONTRACT ->
                    criteria.put(
                            "commons.contractId",
                            businessReference
                    );

            case SDO ->
                    criteria.put(
                            "commons.proposalId",
                            businessReference
                    );

            default ->
                    throw new IllegalArgumentException(
                            "Unsupported case type for file discovery: "
                                    + caseType
                    );
        }

        return criteria;
    }

    private CaseEnum toCaseEnum(CaseType caseType) {

        return switch (caseType) {
            case SDO -> CaseEnum.SDO;
            case CONTRACT -> CaseEnum.CONTRACT;
            case TBC -> CaseEnum.TBC;
        };
    }

    private List<CaseInfo> toCaseInfos(
            SpringDataJaxb.PageDto<Map<String, String>> result
    ) {

        if (result == null
                || result.getContent() == null) {
            return List.of();
        }

        return result.getContent()
                .stream()
                .map(this::toCaseInfo)
                .toList();
    }

    private CaseInfo toCaseInfo(
            Map<String, String> caseData
    ) {

        return new CaseInfo(
                caseData.get("caseReference"),
                caseData.get("country"),
                caseData.get("processType"),
                caseData.get("caseStatus"),
                caseData.get("contractId"),
                caseData.get("proposalId")
        );
    }
}
