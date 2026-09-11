---
                 ┌────────────────────┐
                 │   PURGE CYCLE      │
                 └─────────┬──────────┘
                           │
                           ▼
                  Initialize report
                PURGE_START_TIME = now
                           │
                           ▼
                    TBC Purge Job
                Discovery + direct purge
                           │
                           ▼
                   Finalize report
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
        Count PURGED              Count ERROR_FINAL
              │                         │
              └────────────┬────────────┘
                           ▼
                PURGE_END_TIME = now
                           │
                           ▼
                Update BCP_PURGE_REPORT
                           │
                           ▼
              Generate report file
                           │
                           ▼
                   Send email
             with generated report
                           │
                           ▼
         Delete only PURGED RetentionCase
                           │
                           ▼
             Errors remain in database


                ┌────────────────────────┐
                │      TBC DISCOVERY     │
                └───────────┬────────────┘
                            │
                            ▼
                   AMX findCaseByCriteria
                            │
             creationDate <= cutoff date
                            │
                            ▼
                 max N cases returned
                            │
                            ▼
                  BCP_RETENTION_CASE
                            │
                   PURGE_STATUS = READY
                            │
                   no archive required
                            │
                            ▼
                       TBC PURGE
