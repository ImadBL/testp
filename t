
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface RetentionCaseRepository
        extends JpaRepository<RetentionCase, Long> {

    /*
     * Recherche d'une case déjà connue.
     * Utile notamment pendant la discovery pour éviter les doublons.
     */
    Optional<RetentionCase> findBySourceTypeAndCaseReference(
            SourceType sourceType,
            String caseReference
    );

    boolean existsBySourceTypeAndCaseReference(
            SourceType sourceType,
            String caseReference
    );

    /*
     * Backlog de purge.
     */
    long countBySourceTypeInAndPurgeStatusIn(
            Collection<SourceType> sourceTypes,
            Collection<PurgeStatus> purgeStatuses
    );

    /*
     * Cases disponibles pour la purge.
     *
     * Le verrou pessimiste évite que deux workers prennent
     * simultanément les mêmes lignes.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            select rc
              from RetentionCase rc
             where rc.purgeStatus in :statuses
               and (
                    rc.claimedBy is null
                    or rc.claimedAt < :claimExpiredBefore
               )
             order by rc.id
            """)
    List<RetentionCase> findClaimableForPurge(
            @Param("statuses")
            Collection<PurgeStatus> statuses,

            @Param("claimExpiredBefore")
            Instant claimExpiredBefore,

            Pageable pageable
    );

    /*
     * Une case de purge BLOCKED devient READY
     * lorsque son ArchiveCase associée est ARCHIVED.
     *
     * L'ArchiveService ne modifie donc plus PurgeStatus.
     */
    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
            update RetentionCase rc
               set rc.purgeStatus = :ready,
                   rc.updatedAt = :now
             where rc.purgeStatus = :blocked
               and rc.archiveCase is not null
               and rc.archiveCase.id in (
                    select ac.id
                      from ArchiveCase ac
                     where ac.archiveStatus = :archived
               )
            """)
    int releaseArchivedCasesForPurge(
            @Param("blocked")
            PurgeStatus blocked,

            @Param("ready")
            PurgeStatus ready,

            @Param("archived")
            ArchiveStatus archived,

            @Param("now")
            Instant now
    );
}
