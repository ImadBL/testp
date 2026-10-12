---
@Service
public class PurgeCycleService {

    private final PurgeWindowProperties properties;

    public PurgeCycleService(PurgeWindowProperties properties) {
        this.properties = properties;
    }

    public LocalDate resolvePurgeDate(LocalDateTime launchDateTime) {
        LocalTime launchTime = launchDateTime.toLocalTime();

        LocalTime startTime = properties.getStartTime();
        LocalTime endTime = properties.getEndTime();

        if (isWindowCrossingMidnight(startTime, endTime)) {
            if (!launchTime.isBefore(startTime)) {
                return launchDateTime.toLocalDate();
            }

            if (launchTime.isBefore(endTime)) {
                return launchDateTime.toLocalDate().minusDays(1);
            }
        } else {
            if (!launchTime.isBefore(startTime) && launchTime.isBefore(endTime)) {
                return launchDateTime.toLocalDate();
            }
        }

        throw new IllegalStateException("Batch launched outside purge window");
    }

    private boolean isWindowCrossingMidnight(LocalTime startTime, LocalTime endTime) {
        return endTime.isBefore(startTime);
    }
}


@ConfigurationProperties(prefix = "purge.window")
public class PurgeWindowProperties {

    private LocalTime startTime;
    private LocalTime endTime;

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalTime endTime) {
        this.endTime = endTime;
    }
}
