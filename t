private Object extractComplexValue(FieldType field) {
    if (field.getComplexSpec() == null) {
        return null;
    }

    Object value = field.getComplexSpec().getValue();

    // si c'est enveloppé dans un JAXBElement
    if (value instanceof jakarta.xml.bind.JAXBElement<?> jaxb) {
        return jaxb.getValue();
    }

    return value;
}

private String extractCaseStatus(Object value) {
    if (value == null) {
        return null;
    }

    // Cas direct : l'objet JAXB généré
    if (value instanceof ToCompleteElement toCompleteElement) {
        return toCompleteElement.getCaseStatus();
    }

    // Si besoin, tu peux ajouter d'autres cas ici
    return null;
}
