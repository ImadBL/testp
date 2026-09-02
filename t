package com.bnpp.leasing.batchcasepurge.service;

import com.bnpp.leasing.batchcasepurge.domain.ArchiveStatus;
import com.bnpp.leasing.batchcasepurge.domain.PurgeStatus;
import com.bnpp.leasing.batchcasepurge.repository.RetentionCaseRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Slf4j
@Service
@RequiredArgsConstructor
public class PurgePreparationService {

    private final RetentionCaseRepository repository;

    @Transactional
    public int releaseArchivedCases() {

        int count =
                repository.releaseArchivedCasesForPurge(
                        PurgeStatus.BLOCKED,
                        PurgeStatus.READY,
                        ArchiveStatus.ARCHIVED,
                        Instant.now()
                );

        if (count > 0) {
            log.info(
                    "{} retention case(s) released for purge",
                    count
            );
        }

        return count;
    }
}
