public void transformCaseStatusToSimple(DataModel dataModel) {
    if (dataModel == null || dataModel.getInouts() == null) {
        return;
    }

    List<FieldType> inouts = dataModel.getInouts();

    FieldType complexField = null;
    String caseStatus = null;

    for (FieldType field : inouts) {
        if (field == null) {
            continue;
        }

        if ("Complex".equalsIgnoreCase(field.getType())
                && "ToCompleteCase".equals(field.getName())) {

            complexField = field;

            // 1) Récupérer la valeur du complex
            Object value = extractComplexValue(field);

            // 2) Extraire caseStatus depuis l'objet complexe
            caseStatus = extractCaseStatus(value);
            break;
        }
    }

    if (complexField == null || caseStatus == null || caseStatus.isBlank()) {
        return;
    }

    // 3) Supprimer l'ancien inout complex
    inouts.remove(complexField);

    // 4) Créer le nouveau inout simple
    FieldType simpleField = new FieldType();
    simpleField.setName("caseStatus"); // ou "decision" si c'est ce que tu veux côté XML
    simpleField.setType("simple");

    SimpleSpecType simpleSpec = new SimpleSpecType();
    simpleSpec.setValue(caseStatus);

    simpleField.setSimpleSpec(simpleSpec);

    // 5) Ajouter le nouveau inout simple
    inouts.add(simpleField);
}
