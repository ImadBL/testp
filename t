package com.bnpp.leasing.batchcasepurge.service;

import com.bnpp.leasing.batchcasepurge.domain.ArchiveCase;
import com.bnpp.leasing.batchcasepurge.domain.ArchiveSource;
import com.bnpp.leasing.batchcasepurge.domain.ArchiveStatus;
import com.bnpp.leasing.batchcasepurge.repository.ArchiveCaseRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ArchiveCaseService {

    private final ArchiveCaseRepository repository;

    /**
     * Utilisé par le workflow de purge.
     *
     * Si une ArchiveCase existe déjà pour la case :
     * - on la réutilise telle quelle
     * - on ne change surtout pas son statut
     *
     * Si elle n'existe pas :
     * - création avec PENDING
     * - source = PURGE
     */
    @Transactional
    public ArchiveCase getOrCreateForPurge(
            String caseReference,
            String caseType
    ) {

        validate(caseReference, caseType);

        Optional<ArchiveCase> existing =
                repository.findByCaseReferenceAndCaseType(
                        caseReference,
                        caseType
                );

        if (existing.isPresent()) {

            ArchiveCase archiveCase = existing.get();

            log.debug(
                    "ArchiveCase already exists for purge - caseReference={}, caseType={}, archiveStatus={}",
                    caseReference,
                    caseType,
                    archiveCase.getArchiveStatus()
            );

            return archiveCase;
        }

        Instant now = Instant.now();

        ArchiveCase archiveCase =
                ArchiveCase.builder()
                        .caseReference(caseReference)
                        .caseType(caseType)
                        .source(ArchiveSource.PURGE)
                        .archiveStatus(ArchiveStatus.PENDING)
                        .archiveAttemptCount(0)
                        .createdAt(now)
                        .updatedAt(now)
                        .build();

        ArchiveCase saved =
                repository.save(archiveCase);

        log.info(
                "ArchiveCase created from purge - id={}, caseReference={}, caseType={}",
                saved.getId(),
                caseReference,
                caseType
        );

        return saved;
    }

    /**
     * Utilisé par ArchiveRequestListener.
     *
     * Si la case existe déjà :
     * - on réutilise la même ArchiveCase
     * - on enregistre le JMS_MESSAGE_ID si nécessaire
     * - on ne remet jamais ARCHIVED en REQUESTED
     * - on ne réinitialise pas les erreurs/retries
     *
     * Si elle n'existe pas :
     * - création avec REQUESTED
     * - source = JMS
     */
    @Transactional
    public ArchiveCase registerFromJms(
            String jmsMessageId,
            String caseReference,
            String caseType
    ) {

        validate(caseReference, caseType);

        Optional<ArchiveCase> existing =
                repository.findByCaseReferenceAndCaseType(
                        caseReference,
                        caseType
                );

        if (existing.isPresent()) {

            ArchiveCase archiveCase = existing.get();

            /*
             * La case peut avoir été créée précédemment
             * par le workflow de purge.
             *
             * Dans ce cas, on garde la même ligne.
             */
            if (archiveCase.getJmsMessageId() == null
                    && jmsMessageId != null
                    && !jmsMessageId.isBlank()) {

                archiveCase.setJmsMessageId(
                        jmsMessageId
                );
            }

            archiveCase.setUpdatedAt(
                    Instant.now()
            );

            log.info(
                    "ArchiveCase already exists for JMS - id={}, caseReference={}, status={}",
                    archiveCase.getId(),
                    caseReference,
                    archiveCase.getArchiveStatus()
            );

            return repository.save(archiveCase);
        }

        Instant now = Instant.now();

        ArchiveCase archiveCase =
                ArchiveCase.builder()
                        .caseReference(caseReference)
                        .caseType(caseType)
                        .source(ArchiveSource.JMS)
                        .jmsMessageId(jmsMessageId)
                        .archiveStatus(ArchiveStatus.REQUESTED)
                        .archiveAttemptCount(0)
                        .createdAt(now)
                        .updatedAt(now)
                        .build();

        ArchiveCase saved =
                repository.save(archiveCase);

        log.info(
                "ArchiveCase created from JMS - id={}, caseReference={}, caseType={}, messageId={}",
                saved.getId(),
                caseReference,
                caseType,
                jmsMessageId
        );

        return saved;
    }

    @Transactional(readOnly = true)
    public Optional<ArchiveCase> findByCase(
            String caseReference,
            String caseType
    ) {

        if (caseReference == null
                || caseReference.isBlank()
                || caseType == null
                || caseType.isBlank()) {

            return Optional.empty();
        }

        return repository.findByCaseReferenceAndCaseType(
                caseReference,
                caseType
        );
    }

    @Transactional(readOnly = true)
    public Optional<ArchiveCase> findById(
            Long id
    ) {

        if (id == null) {
            return Optional.empty();
        }

        return repository.findById(id);
    }

    @Transactional(readOnly = true)
    public boolean isArchived(
            String caseReference,
            String caseType
    ) {

        return repository
                .findByCaseReferenceAndCaseType(
                        caseReference,
                        caseType
                )
                .map(archiveCase ->
                        archiveCase.getArchiveStatus()
                                == ArchiveStatus.ARCHIVED
                )
                .orElse(false);
    }

    private void validate(
            String caseReference,
            String caseType
    ) {

        if (caseReference == null
                || caseReference.isBlank()) {

            throw new IllegalArgumentException(
                    "caseReference is mandatory"
            );
        }

        if (caseType == null
                || caseType.isBlank()) {

            throw new IllegalArgumentException(
                    "caseType is mandatory"
            );
        }
    }
}
