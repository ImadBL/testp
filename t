LocalDateTime cycleDateTime = LocalDateTime.of(cycleDate, time);


public Integer getNextCycleNumber(LocalDateTime launchDateTime) {
    if (launchDateTime.toLocalTime().isBefore(LocalTime.of(19, 0))) {
        throw new IllegalStateException("Batch launched outside purge window");
    }

    LocalDateTime windowStart = launchDateTime.toLocalDate().atTime(19, 0);
    LocalDateTime windowEnd = launchDateTime.toLocalDate().plusDays(1).atStartOfDay();

    Integer maxCycleNumber = purgeProcessRepository.findMaxCycleNumberByWindow(
            windowStart,
            windowEnd
    );

    return maxCycleNumber == null ? 1 : maxCycleNumber + 1;
}
