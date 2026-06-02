CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ START WITH 1 INCREMENT BY 1;


public void clearNbDocsExchange(OpenWorkItemDto dataInput) {
    if (dataInput == null
            || dataInput.getCaseData() == null
            || !dataInput.getCaseData().isObject()
            || !dataInput.getCaseData().hasNonNull("customerPortalIdRequest")) {
        return;
    }

    ObjectNode caseData = (ObjectNode) dataInput.getCaseData();

    removeNbDocsExchanged(caseData.get("comments"));
    removeNbDocsExchanged(caseData.get("commentsInternal"));
    removeNbDocsExchanged(caseData.get("commentsExternal"));
}

private void removeNbDocsExchanged(JsonNode node) {
    if (node instanceof ArrayNode comments) {
        for (JsonNode comment : comments) {
            if (comment instanceof ObjectNode objectNode) {
                objectNode.remove("nbDocsExchanged");
            }
        }
    }
}
