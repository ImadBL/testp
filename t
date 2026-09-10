---
@ConfigurationProperties(prefix = "retention.tbc")
public record TbcProperties(
        int maxCasesPerSearch,
        int purgeAfterMonths
) {
}

amx.findEligibleTbcCases(
        properties.maxCasesPerSearch()
);

ZonedDateTime purgeBeforeDate =
        ZonedDateTime.now(ZoneOffset.UTC)
                .minusMonths(properties.purgeAfterMonths());
