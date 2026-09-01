private void archive(ArchiveCase archiveCase) {

    String caseReference =
            archiveCase.getCaseReference();

    if (client.isArchived(caseReference)) {
        return;
    }

    String correlationId =
            getOrCreateCorrelationId(archiveCase);

    client.archive(
            caseReference,
            correlationId
    );

    if (!client.isArchived(caseReference)) {
        throw new IllegalStateException(
                "Archivage non confirmé pour la case "
                        + caseReference
        );
    }
}
