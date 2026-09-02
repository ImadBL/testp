

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ArchiveService {

    private static final int MAX_ERROR_LENGTH = 4000;

    private final ArchiveCaseRepository repository;
    private final ArchiveYClient archiveYClient;
    private final ArchiveProperties properties;

    /**
     * Traite une ArchiveCase déjà claimée par le worker.
     *
     * Chaque case est traitée dans une transaction indépendante.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void process(
            Long archiveCaseId,
            String workerId
    ) {

        ArchiveCase archiveCase = repository.findById(archiveCaseId)
                .orElseThrow(() ->
                        new IllegalStateException(
                                "ArchiveCase not found: " + archiveCaseId
                        )
                );

        if (!canBeProcessedBy(archiveCase, workerId)) {

            log.warn(
                    "ArchiveCase ignored - id={}, caseReference={}, status={}, claimedBy={}, workerId={}",
                    archiveCase.getId(),
                    archiveCase.getCaseReference(),
                    archiveCase.getArchiveStatus(),
                    archiveCase.getClaimedBy(),
                    workerId
            );

            return;
        }

        try {

            incrementAttemptCount(archiveCase);

            archive(archiveCase);

            markArchived(archiveCase);

            log.info(
                    "Archive completed - id={}, caseReference={}, attemptCount={}",
                    archiveCase.getId(),
                    archiveCase.getCaseReference(),
                    archiveCase.getArchiveAttemptCount()
            );

        } catch (Exception exception) {

            markArchiveFailure(
                    archiveCase,
                    exception
            );

            log.error(
                    "Archive failed - id={}, caseReference={}, attemptCount={}, status={}",
                    archiveCase.getId(),
                    archiveCase.getCaseReference(),
                    archiveCase.getArchiveAttemptCount(),
                    archiveCase.getArchiveStatus(),
                    exception
            );

        } finally {

            releaseClaim(archiveCase);

            archiveCase.setUpdatedAt(
                    Instant.now()
            );
        }
    }

    /**
     * Vérifie que cette ligne appartient bien au worker
     * qui essaie de la traiter.
     */
    private boolean canBeProcessedBy(
            ArchiveCase archiveCase,
            String workerId
    ) {

        return archiveCase.getArchiveStatus()
                == ArchiveStatus.IN_PROGRESS

                && Objects.equals(
                        archiveCase.getClaimedBy(),
                        workerId
                );
    }

    /**
     * Exécute réellement l'archivage.
     */
    private void archive(
            ArchiveCase archiveCase
    ) {

        String caseReference =
                archiveCase.getCaseReference();

        /*
         * Important pour l'idempotence :
         * si la case est déjà archivée dans le système cible,
         * on la considère directement comme terminée.
         */
        if (archiveYClient.isArchived(caseReference)) {

            log.info(
                    "Case already archived - caseReference={}",
                    caseReference
            );

            return;
        }

        String correlationId =
                getOrCreateCorrelationId(
                        archiveCase
                );

        archiveYClient.archive(
                caseReference,
                correlationId
        );

        /*
         * Vérification après appel.
         */
        if (!archiveYClient.isArchived(caseReference)) {

            throw new IllegalStateException(
                    "Archive not confirmed for case "
                            + caseReference
            );
        }
    }

    /**
     * Le correlationId doit être conservé entre les retries.
     */
    private String getOrCreateCorrelationId(
            ArchiveCase archiveCase
    ) {

        if (archiveCase.getArchiveCorrelationId()
                == null
                || archiveCase.getArchiveCorrelationId().isBlank()) {

            archiveCase.setArchiveCorrelationId(
                    UUID.randomUUID().toString()
            );
        }

        return archiveCase.getArchiveCorrelationId();
    }

    /**
     * Comme la colonne s'appelle ATTEMPT_COUNT,
     * on compte chaque exécution du traitement.
     */
    private void incrementAttemptCount(
            ArchiveCase archiveCase
    ) {

        archiveCase.setArchiveAttemptCount(
                archiveCase.getArchiveAttemptCount() + 1
        );
    }

    /**
     * Succès de l'archivage.
     *
     * ATTENTION :
     * aucune modification du PurgeStatus ici.
     * ArchiveService ne connaît plus la purge.
     */
    private void markArchived(
            ArchiveCase archiveCase
    ) {

        archiveCase.setArchiveStatus(
                ArchiveStatus.ARCHIVED
        );

        archiveCase.setArchiveDate(
                Instant.now()
        );

        archiveCase.setLastError(null);
    }

    /**
     * Gestion des erreurs et des nouvelles tentatives.
     */
    private void markArchiveFailure(
            ArchiveCase archiveCase,
            Exception exception
    ) {

        archiveCase.setLastError(
                truncateError(exception)
        );

        if (archiveCase.getArchiveAttemptCount()
                >= properties.maxRetries()) {

            archiveCase.setArchiveStatus(
                    ArchiveStatus.ERROR_FINAL
            );

        } else {

            archiveCase.setArchiveStatus(
                    ArchiveStatus.ERROR_RETRYABLE
            );
        }
    }

    private void releaseClaim(
            ArchiveCase archiveCase
    ) {

        archiveCase.setClaimedBy(null);
        archiveCase.setClaimedAt(null);
    }

    private String truncateError(
            Exception exception
    ) {

        String message = exception.getMessage();

        if (message == null || message.isBlank()) {
            message = exception.getClass().getSimpleName();
        }

        if (message.length() <= MAX_ERROR_LENGTH) {
            return message;
        }

        return message.substring(
                0,
                MAX_ERROR_LENGTH
        );
    }
}
