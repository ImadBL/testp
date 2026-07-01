CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

.search-row {
    display: flex;
    align-items: center;
    width: 100%;
    gap: 16px;
}

.search-row .search-input {
    flex: 1 1 0;
    min-width: 0;
}

.search-row .search-button {
    flex: 0 0 auto;
}
