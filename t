---
retention:
  cron:
    purge-cycle: "0 */10 19-23,0-1 * * *"
    purge-notification: "0 5 2 * * *"


@RequiredArgsConstructor
public class PurgeNotificationTasklet implements Tasklet {

    private final PurgeNotificationService service;

    @Override
    public RepeatStatus execute(
            StepContribution contribution,
            ChunkContext chunkContext
    ) {

        service.sendNightlyNotification();

        return RepeatStatus.FINISHED;
    }
}


@Slf4j
@Service
@RequiredArgsConstructor
public class PurgeNotificationService {

    private final PurgeReportRepository reportRepository;
    private final PurgeReportFileService reportFileService;
    private final MailService mailService;

    @Transactional(readOnly = true)
    public void sendNightlyNotification() {

        LocalDate today = LocalDate.now();

        LocalDateTime start =
                today.minusDays(1).atTime(19, 0);

        LocalDateTime end =
                today.atTime(2, 0);

        List<PurgeReport> reports =
                reportRepository.findByPurgeStartTimeBetween(
                        start,
                        end
                );

        PurgeNotificationSummary summary =
                buildSummary(
                        reports,
                        start,
                        end
                );

        Path reportFile =
                reportFileService.generate(summary);

        mailService.sendPurgeReport(
                summary,
                reportFile
        );

        log.info(
                "Purge notification sent for period {} -> {}",
                start,
                end
        );
    }
}




@Bean
PurgeNotificationTasklet purgeNotificationTasklet(
        PurgeNotificationService service
) {
    return new PurgeNotificationTasklet(service);
}



@Bean
Job purgeNotificationJob(
        JobRepository jobRepository,
        PlatformTransactionManager transactionManager,
        PurgeNotificationTasklet tasklet
) {

    Step step =
            new StepBuilder(
                    "purgeNotificationStep",
                    jobRepository
            )
                    .tasklet(
                            tasklet,
                            transactionManager
                    )
                    .build();

    return new JobBuilder(
            "purgeNotificationJob",
            jobRepository
    )
            .start(step)
            .build();
}



private final Job purgeNotificationJob;


@Qualifier("purgeNotificationJob")
Job purgeNotificationJob


this.purgeNotificationJob =
        purgeNotificationJob;



@Scheduled(
        cron = "${retention.cron.purge-notification:0 5 2 * * *}",
        zone = "${retention.window.zone:Europe/Paris}"
)
public void purgeNotification() {

    run(
            purgeNotificationJob,
            "scheduler"
    );
}





