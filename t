CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;

/* Même hauteur pour input et select */
.search-row md-input-container {
    margin: 0;
}

/* Empêche le label du select de bouger différemment */
.search-row md-select {
    display: flex;
    align-items: center;
    min-height: 30px;
}
