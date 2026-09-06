private String buildTbcCriteria() {

    return """
            commons.status='CLOSED'
            AND commons.eligible='true'
            """.replace("\n", " ");
}
