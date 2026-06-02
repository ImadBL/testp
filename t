CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;


Map<String, JobParameter<?>> parameters = new HashMap<>();

parameters.put("launch_date", new JobParameter<>(Instant.now().toEpochMilli(), Long.class));
parameters.put("file", new JobParameter<>(pathTestFile, String.class));
parameters.put("user_id", new JobParameter<>("test", String.class));
parameters.put("user_name", new JobParameter<>("test", String.class));

JobParameters jobParameters = new JobParameters(parameters);
