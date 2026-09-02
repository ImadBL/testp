@Lock(LockModeType.PESSIMISTIC_WRITE)
@Query("""
        select rc
          from RetentionCase rc
         where rc.caseType in :caseTypes
           and rc.purgeStatus = :purgeStatus
           and (
                rc.claimedBy is null
                or rc.claimedAt < :expired
               )
         order by rc.id
        """)
List<RetentionCase> findFilePurgeCandidates(
        @Param("caseTypes")
        Collection<CaseType> caseTypes,

        @Param("purgeStatus")
        PurgeStatus purgeStatus,

        @Param("expired")
        Instant expired,

        Pageable pageable
);
