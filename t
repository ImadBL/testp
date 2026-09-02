    @Modifying(
            clearAutomatically = true,
            flushAutomatically = true
    )
    @Query("""
            update RetentionCase rc
               set rc.purgeStatus = :ready,
                   rc.updatedAt = :now
             where rc.purgeStatus = :blocked
               and rc.archiveCase is not null
               and rc.archiveCase.archiveStatus = :archived
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
