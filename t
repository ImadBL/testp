LocalDateTime windowStart = purgeDate.atTime(startTime);           // 09/10 19:00
LocalDateTime windowEnd = purgeDate.plusDays(1).atTime(endTime);   // 10/10 02:00

@Query("""
    select max(p.cycleNumber)
    from PurgeProcess p
    where p.startDate >= :windowStart
      and p.startDate < :windowEnd
""")
Integer findMaxCycleNumberByWindow(
        @Param("windowStart") LocalDateTime windowStart,
        @Param("windowEnd") LocalDateTime windowEnd
);

Integer maxCycleNumber = repository.findMaxCycleNumberByWindow(windowStart, windowEnd);
int nextCycleNumber = maxCycleNumber == null ? 1 : maxCycleNumber + 1;
