---
@Slf4j
@Component
@ConditionalOnProperty(
        name = "retention.scheduler.enabled",
        havingValue = "true",
        matchIfMissing = true
)
public class BatchScheduler {

    private final JobLauncher launcher;

    private final Job fileImportJob;
    private final Job caseDiscoveryJob;
    private final Job archiveJob;

    private final Job filePurgeJob;
    private final Job tbcJob;

    private final Job purgeReportInitJob;
    private final Job purgeReportFinalizeJob;

    public BatchScheduler(
            JobLauncher launcher,
            @Qualifier("fileImportJob") Job fileImportJob,
            @Qualifier("caseDiscoveryJob") Job caseDiscoveryJob,
            @Qualifier("archiveJob") Job archiveJob,
            @Qualifier("filePurgeJob") Job filePurgeJob,
            @Qualifier("tbcAutoPurgeJob") Job tbcJob,
            @Qualifier("purgeReportInitJob") Job purgeReportInitJob,
            @Qualifier("purgeReportFinalizeJob") Job purgeReportFinalizeJob
    ) {
        this.launcher = launcher;
        this.fileImportJob = fileImportJob;
        this.caseDiscoveryJob = caseDiscoveryJob;
        this.archiveJob = archiveJob;
        this.filePurgeJob = filePurgeJob;
        this.tbcJob = tbcJob;
        this.purgeReportInitJob = purgeReportInitJob;
        this.purgeReportFinalizeJob = purgeReportFinalizeJob;
    }

    private void run(Job job, String trigger) {

        try {

            var parameters = new JobParametersBuilder()
                    .addString("trigger", trigger)
                    .addLong(
                            "timestamp",
                            System.currentTimeMillis()
                    )
                    .toJobParameters();

            var execution =
                    launcher.run(job, parameters);

            if (execution.getStatus()
                    != BatchStatus.COMPLETED) {

                throw new IllegalStateException(
                        "Job "
                                + job.getName()
                                + " ended with status "
                                + execution.getStatus()
                );
            }

        } catch (Exception exception) {

            throw new IllegalStateException(
                    "Unable to launch "
                            + job.getName(),
                    exception
            );
        }
    }

    @Scheduled(
            cron = "${retention.cron.file-import:0 0/10 18-23,0-1 * * *}",
            zone = "${retention.window.zone:Europe/Paris}"
    )
    public void fileImport() {
        run(fileImportJob, "scheduler");
    }

    @Scheduled(
            cron = "${retention.cron.case-discovery:0 2/10 18-23,0-1 * * *}",
            zone = "${retention.window.zone:Europe/Paris}"
    )
    public void caseDiscovery() {
        run(caseDiscoveryJob, "scheduler");
    }

    @Scheduled(
            cron = "${retention.cron.archive:0 4/10 18-23,0-1 * * *}",
            zone = "${retention.window.zone:Europe/Paris}"
    )
    public void archive() {
        run(archiveJob, "scheduler");
    }

    @Scheduled(
            cron = "${retention.cron.purge-cycle:0 8/10 18-23,0-1 * * *}",
            zone = "${retention.window.zone:Europe/Paris}"
    )
    public void purgeCycle() {

        boolean reportStarted = false;

        try {

            run(
                    purgeReportInitJob,
                    "purge-cycle"
            );

            reportStarted = true;

            run(
                    filePurgeJob,
                    "purge-cycle"
            );

            run(
                    tbcJob,
                    "purge-cycle"
            );

        } catch (Exception exception) {

            log.error(
                    "Erreur pendant le cycle de purge",
                    exception
            );

        } finally {

            if (reportStarted) {

                try {

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
}
