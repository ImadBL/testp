---
private void validateFileCase(RetentionCase retentionCase) {

    if (retentionCase.getCaseType() == CaseType.TBC) {
        throw new InvalidPurgeConfigurationException(
                "Une case TBC ne doit pas être traitée par la purge fichier"
        );
    }

    if (retentionCase.getArchiveCase() == null) {
        throw new InvalidPurgeConfigurationException(
                "Aucune information d'archivage associée à la case"
        );
    }

    if (retentionCase.getArchiveCase().getArchiveStatus()
            != ArchiveStatus.ARCHIVED) {

        throw new InvalidPurgeConfigurationException(
                "Archivage obligatoire non confirmé"
        );
    }
}

private void validateTbcCase(RetentionCase retentionCase) {

    if (retentionCase.getCaseType() != CaseType.TBC) {
        throw new InvalidPurgeConfigurationException(
                "La case n'est pas de type TBC"
        );
    }

    if (retentionCase.getArchiveCase() != null) {
        throw new InvalidPurgeConfigurationException(
                "Une case TBC ne doit pas avoir d'archivage associé"
        );
    }
}

private void markTechnicalFailure(
        RetentionCase retentionCase,
        Exception exception
) {

    int attemptCount =
            retentionCase.getPurgeAttemptCount() + 1;

    retentionCase.setPurgeAttemptCount(
            attemptCount
    );

    retentionCase.setLastError(
            truncateError(exception)
    );

    if (attemptCount >= properties.maxAttempts()) {

        retentionCase.setPurgeStatus(
                PurgeStatus.ERROR_FINAL
        );

    } else {

        retentionCase.setPurgeStatus(
                PurgeStatus.ERROR_RETRYABLE
        );
    }
}

private void markFinalFailure(
        RetentionCase retentionCase,
        Exception exception
) {

    retentionCase.setPurgeAttemptCount(
            retentionCase.getPurgeAttemptCount() + 1
    );

    retentionCase.setPurgeStatus(
            PurgeStatus.ERROR_FINAL
    );

    retentionCase.setLastError(
            truncateError(exception)
    );
}
