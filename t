---
@Scheduled(
        cron = "${retention.cron.purge-cycle:0 8/10 18-23,0-1 * * *}",
        zone = "${retention.window.zone:Europe/Paris}"
)
public void purgeCycle() {

    boolean reportStarted = false;

    try {

        // 1. Ouverture du rapport
        run(purgeReportInitJob, "purge-cycle");
        reportStarted = true;

        // 2. Purge SDO / CONTRACT déjà prêts
        run(filePurgeJob, "purge-cycle");

        // 3. Discovery + purge TBC
        run(tbcJob, "purge-cycle");

    } catch (Exception exception) {

        log.error(
                "Erreur pendant le cycle de purge",
                exception
        );

    } finally {

        if (reportStarted) {
            try {

                // 4. Calcul rapport + clean des PURGED
                run(
                        purgeReportFinalizeJob,
                        "purge-cycle"
                );

            } catch (Exception exception) {

                log.error(
                        "Erreur pendant la finalisation du rapport de purge",
                        exception
                );
            }
        }
    }
}
