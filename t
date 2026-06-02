CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;


public void clearNbDocsMsgAttachment(OpenWorkItemDto dataInput) {
    if (dataInput == null
            || dataInput.getCaseData() == null
            || !dataInput.getCaseData().isObject()) {
        return;
    }

    JsonNode msg = dataInput.getCaseData().get("documents");

    if (msg instanceof ArrayNode msgs) {
        for (JsonNode m : msgs) {
            if (m instanceof ObjectNode objectNode) {
                objectNode.remove("messageAttachment");
            }
        }
    }
}
