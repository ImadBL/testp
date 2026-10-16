public LocalDateTimeObjDTO resolvePurgeDate(LocalDateTime launchDateTime) {
    LocalTime launchTime = launchDateTime.toLocalTime();
    LocalTime startTime = properties.getStart();
    LocalTime endTime = properties.getStopNewWork();

    boolean crossesMidnight =
            isWindowCrossingMidnight(startTime, endTime);

    LocalDate cycleDate = launchDateTime.toLocalDate();

    // Après minuit, rattacher le cycle à la veille
    // tant que la fenêtre nocturne n'est pas terminée.
    if (crossesMidnight && launchTime.isBefore(endTime)) {
        cycleDate = cycleDate.minusDays(1);
    }

    LocalDateTime windowStart = cycleDate.atTime(startTime);

    LocalDate endDate = crossesMidnight
            ? cycleDate.plusDays(1)
            : cycleDate;

    LocalDateTime windowEnd = endDate.atTime(endTime);

    return new LocalDateTimeObjDTO(windowStart, windowEnd);
}
