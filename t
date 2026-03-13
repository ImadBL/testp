-Djava.net.preferIPv4Stack=true

System.out.println("AS400 host=" + host);
System.out.println("AS400 port=" + port);
System.out.println("remoteIPClient=" + remoteIpClient);
System.out.println("terminalType=" + terminalType);
System.out.println("timeout=" + timeout);


@Override
public void completeWorkItem(long workItemId, OpenWorkItemDto payload, Map<String, String> payoutParameters)
        throws CompleteWorkItemException {
    try {
        CompleteWorkItem completeWorkItem =
                itemReworkMapper.createCompleteWorkItem(workItemId, payload, payoutParameters);

        DataModel dm = completeWorkItem.getWorkItemPayload().getDataModel();

        if (dm.getInOuts() == null) {
            dm.setInOuts(new ArrayList<>());
        }

        dm.getInOuts().removeIf(f ->
                f != null && "complex".equalsIgnoreCase(f.getType()));

        boolean hasSimpleDecision = dm.getInOuts().stream()
                .anyMatch(f -> f != null
                        && "simple".equalsIgnoreCase(f.getType())
                        && "decision".equalsIgnoreCase(f.getName()));

        if (!hasSimpleDecision) {
            FieldType field = new FieldType();
            field.setName("decision");
            field.setType("simple");
            dm.getInOuts().add(field);
        }

        completeWorkItem.getWorkItemPayload().setDataModel(dm);
        workItemManagementService.completeWorkItem(completeWorkItem);

    } catch (Exception e) {
        log.error("Error during the completion of the item", e);
        throw new CompleteWorkItemException("Error during the complete workitem action", e);
    }
}
