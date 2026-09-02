package com.bnpp.leasing.batchcasepurge.repository;

import com.bnpp.leasing.batchcasepurge.domain.ArchiveCase;
import com.bnpp.leasing.batchcasepurge.domain.ArchiveStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
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

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            select ac
              from ArchiveCase ac
             where (
                    ac.archiveStatus in :statuses
                    and ac.claimedBy is null
                   )
                or (
                    ac.archiveStatus = :inProgress
                    and ac.claimedAt < :expired
                   )
             order by ac.id
            """)
    List<ArchiveCase> findArchiveCandidates(
            @Param("statuses")
            Collection<ArchiveStatus> statuses,

            @Param("inProgress")
            ArchiveStatus inProgress,

            @Param("expired")
            Instant expired,

            Pageable pageable
    );
}
