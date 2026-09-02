    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            select rc
              from RetentionCase rc
             where rc.sourceType = :sourceType
               and rc.purgeStatus = :purgeStatus
               and (
                    rc.claimedBy is null
                    or rc.claimedAt < :expired
               )
             order by rc.id
            """)
    List<RetentionCase> findTbcCandidates(
            @Param("sourceType")
            CaseType sourceType,

            @Param("purgeStatus")
            PurgeStatus purgeStatus,

            @Param("expired")
            Instant expired,

            Pageable pageable
    );

