---
@Query("""
    select count(rc)
      from RetentionCase rc
     where rc.caseType = :caseType
       and rc.purgeStatus = :purgeStatus
       and rc.updatedAt >= :start
       and rc.updatedAt <= :end
    """)
long countForReport(
        @Param("caseType") CaseType caseType,
        @Param("purgeStatus") PurgeStatus purgeStatus,
        @Param("start") Instant start,
        @Param("end") Instant end
);

@Query("""
    select count(rc)
      from RetentionCase rc
     where rc.caseType = :caseType
       and rc.purgeStatus in :statuses
       and rc.updatedAt >= :start
       and rc.updatedAt <= :end
    """)
long countErrorsForReport(
        @Param("caseType") CaseType caseType,
        @Param("statuses") Collection<PurgeStatus> statuses,
        @Param("start") Instant start,
        @Param("end") Instant end
);


List.of(
    PurgeStatus.ERROR_RETRYABLE,
    PurgeStatus.ERROR_FINAL
)


@Modifying
@Query("""
    delete from RetentionCase rc
     where rc.purgeStatus = :purgeStatus
    """)
int deleteByPurgeStatus(
        @Param("purgeStatus") PurgeStatus purgeStatus
);


PurgeStatus.PURGED


@Slf4j
@Service
@RequiredArgsConstructor
public class PurgeReportService {

    private final PurgeReportRepository reportRepository;
    private final RetentionCaseRepository retentionCaseRepository;

    @Transactional
    public Long startReport() {

        Instant now = Instant.now();

        PurgeReport report = PurgeReport.builder()
                .purgeStartTime(now)
                .purgeEndTime(null)
                .payoutPurged(0L)
                .customerServicePurged(0L)
                .toBeCompletedPurged(0L)
                .payoutPurgeError(0L)
                .customerServicePurgeError(0L)
                .toBeCompletedPurgeError(0L)
                .build();

        report = reportRepository.save(report);

        log.info(
                "Rapport de purge initialisé id={}, startTime={}",
                report.getId(),
                now
        );

        return report.getId();
    }
}


@Transactional
public void finalizeReport() {

    PurgeReport report = reportRepository
            .findFirstByPurgeEndTimeIsNullOrderByPurgeStartTimeDesc()
            .orElseThrow(() ->
                    new IllegalStateException(
                            "Aucun rapport de purge en cours"
                    )
            );

    Instant start = report.getPurgeStartTime();
    Instant end = Instant.now();

    // compteurs SUCCESS

    report.setPayoutPurged(
            retentionCaseRepository.countForReport(
                    CaseType.PAYOUT,
                    PurgeStatus.PURGED,
                    start,
                    end
            )
    );

    report.setCustomerServicePurged(
            retentionCaseRepository.countForReport(
                    CaseType.CUSTOMER_SERVICE,
                    PurgeStatus.PURGED,
                    start,
                    end
            )
    );

    report.setToBeCompletedPurged(
            retentionCaseRepository.countForReport(
                    CaseType.TBC,
                    PurgeStatus.PURGED,
                    start,
                    end
            )
    );

    var errorStatuses = List.of(
            PurgeStatus.ERROR_RETRYABLE,
            PurgeStatus.ERROR_FINAL
    );

    // compteurs ERROR

    report.setPayoutPurgeError(
            retentionCaseRepository.countErrorsForReport(
                    CaseType.PAYOUT,
                    errorStatuses,
                    start,
                    end
            )
    );

    report.setCustomerServicePurgeError(
            retentionCaseRepository.countErrorsForReport(
                    CaseType.CUSTOMER_SERVICE,
                    errorStatuses,
                    start,
                    end
            )
    );

    report.setToBeCompletedPurgeError(
            retentionCaseRepository.countErrorsForReport(
                    CaseType.TBC,
                    errorStatuses,
                    start,
                    end
            )
    );

    report.setPurgeEndTime(end);

    reportRepository.save(report);

    int deleted =
            retentionCaseRepository.deleteByPurgeStatus(
                    PurgeStatus.PURGED
            );

    log.info(
            "Rapport de purge terminé id={}, {} case(s) PURGED supprimée(s)",
            report.getId(),
            deleted
    );
}


@RequiredArgsConstructor
public class PurgeReportInitTasklet implements Tasklet {

    private final PurgeReportService service;

    @Override
    public RepeatStatus execute(
            StepContribution contribution,
            ChunkContext chunkContext
    ) {

        service.startReport();

        return RepeatStatus.FINISHED;
    }
}



@RequiredArgsConstructor
public class PurgeReportFinalizeTasklet implements Tasklet {

    private final PurgeReportService service;

    @Override
    public RepeatStatus execute(
            StepContribution contribution,
            ChunkContext chunkContext
    ) {

        service.finalizeReport();

        return RepeatStatus.FINISHED;
    }
}


@Bean
PurgeReportInitTasklet purgeReportInitTasklet(
        PurgeReportService purgeReportService
) {
    return new PurgeReportInitTasklet(
            purgeReportService
    );
}

@Bean
PurgeReportFinalizeTasklet purgeReportFinalizeTasklet(
        PurgeReportService purgeReportService
) {
    return new PurgeReportFinalizeTasklet(
            purgeReportService
    );
}



@Bean
Step purgeReportInitStep(
        JobRepository jobRepository,
        PlatformTransactionManager transactionManager,
        PurgeReportInitTasklet tasklet
) {

    return new StepBuilder(
            "purgeReportInitStep",
            jobRepository
    )
            .tasklet(
                    tasklet,
                    transactionManager
            )
            .build();
}



@Bean
Step purgeReportFinalizeStep(
        JobRepository jobRepository,
        PlatformTransactionManager transactionManager,
        PurgeReportFinalizeTasklet tasklet
) {

    return new StepBuilder(
            "purgeReportFinalizeStep",
            jobRepository
    )
            .tasklet(
                    tasklet,
                    transactionManager
            )
            .build();
}



