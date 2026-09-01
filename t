private String getOrCreateCorrelationId(
        ArchiveCase archiveCase
) {

    if (archiveCase.getArchiveCorrelationId() == null) {

        archiveCase.setArchiveCorrelationId(
                UUID.randomUUID().toString()
        );
    }

    return archiveCase.getArchiveCorrelationId();
}

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
