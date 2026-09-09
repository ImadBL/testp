---
private void run(Job job, String trigger) {
    try {

        var parameters = new JobParametersBuilder()
                .addString("trigger", trigger)
                .addLong("timestamp", System.currentTimeMillis())
                .toJobParameters();

        var execution = launcher.run(job, parameters);

        if (execution.getStatus() != BatchStatus.COMPLETED) {
            throw new IllegalStateException(
                    "Job " + job.getName()
                            + " ended with status "
                            + execution.getStatus()
            );
        }

    } catch (Exception exception) {
        throw new IllegalStateException(
                "Unable to launch " + job.getName(),
                exception
        );
    }
}
