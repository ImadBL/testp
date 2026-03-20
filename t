import com.microsoft.graph.models.MailFolder;
import com.microsoft.graph.models.MailFolderCollectionResponse;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

private Optional<MailFolder> findRootFolderByNameOrCreateIt(String mailBox, String rootFolder) throws ApiException {
    try {
        init();

        MailFolder foundFolder = findRootFolderByName(mailBox, rootFolder);
        if (foundFolder != null) {
            return Optional.of(foundFolder);
        }

        MailFolder newMailFolder = new MailFolder();
        newMailFolder.setDisplayName(rootFolder);

        MailFolder createdFolder = graphServiceClient
            .users()
            .byUserId(mailBox)
            .mailFolders()
            .post(newMailFolder, r -> addRequestOptions(r.headers));

        if (createdFolder != null) {
            log.info("Create du dossier {} avec id {}", rootFolder, createdFolder.getId());
        }

        return Optional.ofNullable(createdFolder);

    } catch (ApiException e) {
        log.error("Error to find or create root folder {} for mailbox {}", rootFolder, mailBox, e);
        throw e;
    } catch (Exception e) {
        log.error("Erreur pour la création du dossier {}", rootFolder, e);
        return Optional.empty();
    }
}

private MailFolder findRootFolderByName(String mailBox, String rootFolder) throws ApiException {
    MailFolderCollectionResponse page;

    try {
        init();

        page = graphServiceClient
            .users()
            .byUserId(mailBox)
            .mailFolders()
            .get(r -> {
                addRequestOptions(r.headers);
                r.queryParameters.top = 100;
            });

    } catch (ApiException e) {
        log.error("Error to find folders for mailbox {}", mailBox, e);
        throw e;
    }

    while (page != null) {
        if (page.getValue() != null) {
            for (MailFolder folder : page.getValue()) {
                if (folder.getDisplayName() != null
                    && folder.getDisplayName().equalsIgnoreCase(rootFolder)) {
                    return folder;
                }
            }
        }

        String nextLink = page.getOdataNextLink();
        if (nextLink == null || nextLink.isBlank()) {
            break;
        }

        page = graphServiceClient
            .users()
            .byUserId(mailBox)
            .mailFolders()
            .withUrl(nextLink)
            .get();
    }

    return null;
}
