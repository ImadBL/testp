CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

L’erreur ne semble pas être liée aux imports : les processus ont bien été importés et sont correctement présents en base.

Il faudrait analyser ce bug plus en détail avec Samia afin d’identifier pourquoi les dossiers sont créés directement avec un SLA à 0 jour.
