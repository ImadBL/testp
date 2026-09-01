
private void markArchiveFailure(
        ArchiveCase archiveCase,
        Exception exception
) {

    int attemptCount =
            archiveCase.getArchiveAttemptCount() + 1;

    archiveCase.setArchiveAttemptCount(
            attemptCount
    );

    archiveCase.setLastError(
            truncateError(exception)
    );

    if (attemptCount >= properties.maxRetries()) {

        archiveCase.setArchiveStatus(
                ArchiveStatus.ERROR_FINAL
        );

    } else {

        archiveCase.setArchiveStatus(
                ArchiveStatus.ERROR_RETRYABLE
        );
    }
}
