package com.bnpp.leasing.batchcasepurge.repository;

import com.bnpp.leasing.batchcasepurge.domain.ArchiveCase;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ArchiveCaseRepository
        extends JpaRepository<ArchiveCase, Long> {

    Optional<ArchiveCase> findByCaseReferenceAndCaseType(
            String caseReference,
            String caseType
    );

    Optional<ArchiveCase> findByJmsMessageId(
            String jmsMessageId
    );

    boolean existsByJmsMessageId(
            String jmsMessageId
    );
}
