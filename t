---
private String buildTbcCriteria() {

    String limitDate = formatDate(
            ZonedDateTime.now(ZoneOffset.UTC)
                    .minusMonths(24)
    );

    return "commons.creationDate<=" + limitDate;
}

private String formatDate(ZonedDateTime date) {

    DateTimeFormatter formatter =
            DateTimeFormatter.ofPattern(
                    "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            );

    return date
            .withZoneSameInstant(ZoneOffset.UTC)
            .format(formatter);
}
