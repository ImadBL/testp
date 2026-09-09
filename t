---
@Transactional
public void finalizeReport() {

    PurgeReport report = reportRepository
            .findFirstByPurgeEndTimeIsNullOrderByPurgeStartTimeDesc()
            .orElseThrow(() ->
                    new IllegalStateException(
                            "Aucun rapport de purge en cours"
                    )
            );

    LocalDateTime startTime = report.getPurgeStartTime();
    LocalDateTime endTime = LocalDateTime.now();

    ZoneId zone = ZoneId.of("Europe/Paris");

    Instant start = startTime.atZone(zone).toInstant();
    Instant end = endTime.atZone(zone).toInstant();

    // 1. Calcul des compteurs
    fillReportCounters(report, start, end);

    // 2. Aucun traitement effectué => pas de rapport
    if (isEmptyReport(report)) {

        reportRepository.delete(report);

        log.info(
                "Aucune purge effectuée entre {} et {}, rapport supprimé",
                startTime,
                endTime
        );

        return;
    }

    // 3. Finalisation du rapport
    report.setPurgeEndTime(endTime);

    reportRepository.saveAndFlush(report);

    // 4. Clean uniquement des PURGED
    int deleted = retentionCaseRepository
            .deleteByPurgeStatus(PurgeStatus.PURGED);

    log.info(
            "Rapport de purge terminé id={}, {} case(s) supprimée(s)",
            report.getId(),
            deleted
    );
}
