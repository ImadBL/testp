---
@Transactional
public int discover(int pageSize) {

    int page = 0;
    int count = 0;
    boolean hasMore;

    do {

        CaseSearchResult result =
                amx.findEligibleTbcCases(
                        page,
                        pageSize
                );

        if (result.cases().isEmpty()) {
            break;
        }

        for (CaseInfo info : result.cases()) {

            if (repository.existsByCaseTypeAndCaseReference(
                    CaseType.TBC,
                    info.caseReference()
            )) {
                continue;
            }

            Instant now = Instant.now();

            RetentionCase retentionCase =
                    RetentionCase.builder()
                            .caseType(CaseType.TBC)
                            .caseReference(info.caseReference())
                            .caseIdentifier(info.caseIdentifier())
                            .caseStatus(info.caseStatus())
                            .eligible(true)
                            .archiveCase(null)
                            .purgeStatus(PurgeStatus.READY)
                            .purgeAttemptCount(0)
                            .createdAt(now)
                            .updatedAt(now)
                            .build();

            repository.save(retentionCase);

            count++;
        }

        hasMore = result.hasMore();

        page++;

    } while (hasMore);

    return count;
}
