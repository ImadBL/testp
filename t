private CaseContext loadCaseContext(CommentRequestDto request)

private String generateMessageId()

private void validateRequest(CommentRequestDto request)

private void processAttachedDocuments(CaseContext context, CommentRequestDto request, String messageId)

private void processUploadedDocuments(CaseContext context, CommentRequestDto request, String messageId)

private void addCommentToCase(CaseContext context, CommentRequestDto request, String messageId)

private void applyCaseSpecificRules(CaseContext context, boolean hasUploadedDocuments)

private void saveCase(CaseContext context)

private FinalizeCommentResponse buildResponse(String messageId)

CaseContext

CaseContextprivate String caseId;
private CaseEnum caseEnum;
private String caseReference;
private Case caseProxy;
private User user;
private String userName;
private String refogId;
private String organismId;


public CaseContext loadAndAuthorize(CommentRequestDto request)

private String findCaseReference(String caseId, CaseEnum caseEnum)

private Case loadCase(String caseReference)

private void checkAuthorization(Case caseProxy, String caseReference, User user)

private String resolveOrganismId(Case caseProxy)
