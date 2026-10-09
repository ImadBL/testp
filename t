---
public PurgeWindow resolvePurgeWindow(LocalDateTime launchDateTime) {
    LocalTime launchTime = launchDateTime.toLocalTime();

    LocalDate windowStartDate;

    if (!launchTime.isBefore(LocalTime.of(19, 0))) {
        windowStartDate = launchDateTime.toLocalDate();
    } else if (launchTime.isBefore(LocalTime.of(2, 0))) {
        windowStartDate = launchDateTime.toLocalDate().minusDays(1);
    } else {
        throw new IllegalStateException("Batch launched outside purge window");
    }

    LocalDateTime start = windowStartDate.atTime(19, 0);
    LocalDateTime end = windowStartDate.plusDays(1).atTime(2, 0);

    return new PurgeWindow(start, end);
}
