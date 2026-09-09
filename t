---
private boolean isEmptyReport(PurgeReport report) {

    return value(report.getPayoutPurged()) == 0
            && value(report.getCustomerServicePurged()) == 0
            && value(report.getToBeCompletedPurged()) == 0
            && value(report.getPayoutPurgeError()) == 0
            && value(report.getCustomerServicePurgeError()) == 0
            && value(report.getToBeCompletedPurgeError()) == 0;
}

private long value(Long value) {
    return value == null ? 0L : value;
}
