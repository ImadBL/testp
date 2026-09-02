@Service
@RequiredArgsConstructor
public class ArchiveCaseService {

    private final ArchiveCaseRepository repository;

    @Transactional
    public ArchiveCase getOrCreateForPurge(
            String caseReference,
            String caseType
    ) {

        return repository
                .findByCaseReferenceAndCaseType(
                        caseReference,
                        caseType
                )
                .orElseGet(() -> {

                    ArchiveCase archiveCase =
                            ArchiveCase.builder()
                                    .caseReference(caseReference)
                                    .caseType(caseType)
                                    .source("PURGE")
                                    .archiveStatus(
                                            ArchiveStatus.PENDING
                                    )
                                    .archiveAttemptCount(0)
                                    .createdAt(Instant.now())
                                    .updatedAt(Instant.now())
                                    .build();

                    return repository.save(
                            archiveCase
                    );
                });
    }
}
