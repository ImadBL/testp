@Service
@Slf4j
@RequiredArgsConstructor
public class ArchiveService {

    private static final int MAX_ERROR_LENGTH = 4000;

    private final ArchiveCaseRepository repository;
    private final ArchiveYClient client;
    private final ArchiveProperties properties;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void process(Long id, String workerId) {

        ArchiveCase archiveCase = repository.findById(id)
                .orElseThrow(() ->
                        new IllegalStateException(
                                "ArchiveCase introuvable : " + id
                        )
                );

        if (!canBeProcessedBy(archiveCase, workerId)) {

            log.warn(
                    "Archivage ignoré case={}, status={}, claimedBy={}, worker={}",
                    archiveCase.getCaseReference(),
                    archiveCase.getArchiveStatus(),
                    archiveCase.getClaimedBy(),
                    workerId
            );

            return;
        }

        try {

            archive(archiveCase);
            markArchived(archiveCase);

            log.info(
                    "Case {} archivée avec succès",
                    archiveCase.getCaseReference()
            );

        } catch (Exception exception) {

            markArchiveFailure(
                    archiveCase,
                    exception
            );

            log.error(
                    "Erreur pendant l'archivage de la case {}",
                    archiveCase.getCaseReference(),
                    exception
            );

        } finally {

            releaseClaim(archiveCase);
        }
    }
