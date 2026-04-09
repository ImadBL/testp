    CaseContext context = loadAndCheckCase(request);

    String messageId = messageIdGenerator.generate();

    prepareAttachedDocumentsForMessage(context, request, messageId);
    prepareUploadedDocuments(context, request, messageId);
    appendComment(context, request, messageId);
    appendAudits(context, request);
    applyCaseSpecificRules(context, request);

    tibcoCaseService.updateCase(context.caseReference(), context.caseProxy());

    return new FinalizeCommentResponse(messageId);

