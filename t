package com.bnpp.leasing.batchcasepurge.service;

import com.bnpp.leasing.batchcasepurge.domain.ArchiveCase;
import com.bnpp.leasing.batchcasepurge.domain.ArchiveStatus;
import com.bnpp.leasing.batchcasepurge.domain.CaseType;
import com.bnpp.leasing.batchcasepurge.domain.PurgeStatus;
import com.bnpp.leasing.batchcasepurge.domain.RetentionCase;
import com.bnpp.leasing.batchcasepurge.repository.ArchiveCaseRepository;
import com.bnpp.leasing.batchcasepurge.repository.RetentionCaseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CaseClaimService {

    private final RetentionCaseRepository retentionCaseRepository;
    private final ArchiveCaseRepository archiveCaseRepository;

    private Instant expired() {
        return Instant.now()
                .minus(Duration.ofMinutes(30));
    }

    /*
     * ==========================================================
     * ARCHIVAGE
     * ==========================================================
     *
     * Maintenant on claim dans BCP_ARCHIVE_CASE.
     *
     * Les archives peuvent venir :
     * - du workflow PURGE       -> PENDING
     * - du listener JMS         -> REQUESTED
     * - d'un retry              -> ERROR_RETRYABLE
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public List<Long> claimArchive(
            int size,
            String worker
    ) {

        Instant now = Instant.now();

        var rows =
                archiveCaseRepository.findArchiveCandidates(
                        List.of(
                                ArchiveStatus.PENDING,
                                ArchiveStatus.REQUESTED,
                                ArchiveStatus.ERROR_RETRYABLE
                        ),
                        ArchiveStatus.IN_PROGRESS,
                        expired(),
                        PageRequest.of(0, size)
                );

        rows.forEach(archiveCase -> {

            archiveCase.setArchiveStatus(
                    ArchiveStatus.IN_PROGRESS
            );

            archiveCase.setClaimedBy(worker);
            archiveCase.setClaimedAt(now);
            archiveCase.setUpdatedAt(now);
        });

        return archiveCaseRepository
                .saveAll(rows)
                .stream()
                .map(ArchiveCase::getId)
                .toList();
    }

    /*
     * ==========================================================
     * PURGE SDO / CONTRACT
     * ==========================================================
     *
     * Plus besoin de vérifier ArchiveStatus.ARCHIVED ici.
     *
     * PurgePreparationService aura déjà fait :
     *
     * BLOCKED + ArchiveCase.ARCHIVED
     *              ->
     * READY
     *
     * Donc ici on ne prend que les RetentionCase READY.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public List<Long> claimFilePurge(
            int size,
            String worker
    ) {

        Instant now = Instant.now();

        var rows =
                retentionCaseRepository.findFilePurgeCandidates(
                        List.of(
                                CaseType.SDO,
                                CaseType.CONTRACT
                        ),
                        PurgeStatus.READY,
                        expired(),
                        PageRequest.of(0, size)
                );

        rows.forEach(retentionCase -> {

            retentionCase.setPurgeStatus(
                    PurgeStatus.IN_PROGRESS
            );

            retentionCase.setClaimedBy(worker);
            retentionCase.setClaimedAt(now);
            retentionCase.setUpdatedAt(now);
        });

        return retentionCaseRepository
                .saveAll(rows)
                .stream()
                .map(RetentionCase::getId)
                .toList();
    }

    /*
     * ==========================================================
     * PURGE TBC
     * ==========================================================
     *
     * TBC ne nécessite pas d'archivage.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public List<Long> claimTbcPurge(
            int size,
            String worker
    ) {

        Instant now = Instant.now();

        var rows =
                retentionCaseRepository.findTbcCandidates(
                        CaseType.TBC,
                        PurgeStatus.READY,
                        expired(),
                        PageRequest.of(0, size)
                );

        rows.forEach(retentionCase -> {

            retentionCase.setPurgeStatus(
                    PurgeStatus.IN_PROGRESS
            );

            retentionCase.setClaimedBy(worker);
            retentionCase.setClaimedAt(now);
            retentionCase.setUpdatedAt(now);
        });

        return retentionCaseRepository
                .saveAll(rows)
                .stream()
                .map(RetentionCase::getId)
                .toList();
    }
}
