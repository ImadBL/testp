import com.microsoft.graph.models.MailFolder;
import com.microsoft.graph.models.MailFolderCollectionResponse;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

private List<MailFolder> getAllChildFolders(String smtpAddress, String parentFolderId) {
    init();

    List<MailFolder> allFolders = new ArrayList<>();

    MailFolderCollectionResponse page = graphServiceClient
        .users()
        .byUserId(smtpAddress)
        .mailFolders()
        .byMailFolderId(parentFolderId)
        .childFolders()
        .get(requestConfiguration -> {
            // optionnel : augmente la taille de page pour limiter le nombre d'appels
            requestConfiguration.queryParameters.top = 100;
        });

    while (page != null) {
        if (page.getValue() != null) {
            allFolders.addAll(page.getValue());
        }

        String nextLink = page.getOdataNextLink();
        if (nextLink == null || nextLink.isBlank()) {
            break;
        }

        page = graphServiceClient
            .users()
            .byUserId(smtpAddress)
            .mailFolders()
            .byMailFolderId(parentFolderId)
            .childFolders()
            .withUrl(nextLink)
            .get();
    }

    return allFolders;
}

List<MailFolder> childFolders =
    getAllChildFolders(mailBoxDTO.getMailBox(), rootMailFolder.get().getId());

boolean archiveFound = false;
boolean rejectFound = false;

for (MailFolder mf : childFolders) {
    if (mf.getDisplayName().equalsIgnoreCase(mailBoxDTO.getArchiveChildPath())) {
        mailBoxDTO.setArchiveChildPathId(mf.getId());
        archiveFound = true;
    }

    if (mf.getDisplayName().equalsIgnoreCase(mailBoxDTO.getRejectChildPath())) {
        mailBoxDTO.setRejectChildPathId(mf.getId());
        rejectFound = true;
    }

    if (archiveFound && rejectFound) {
        break;
    }
}

@Override
public Optional<Object> findFoldersId(MailBoxDTO mailBoxDTO) throws ApiException {
    mailBoxDTO.setChildPath();

    try {
        Optional<MailFolder> rootMailFolder;

        if (mailBoxDTO.getFolderRoot().equalsIgnoreCase("inbox")) {
            init();
            rootMailFolder = Optional.ofNullable(
                graphServiceClient
                    .users()
                    .byUserId(mailBoxDTO.getMailBox())
                    .mailFolders()
                    .byMailFolderId("inbox")
                    .get(r -> addRequestOptions(r.headers))
            );
        } else {
            rootMailFolder = findRootFolderByNameOrCreateIt(
                mailBoxDTO.getMailBox(),
                mailBoxDTO.getFolderRoot()
            );
        }

        if (rootMailFolder.isEmpty()) {
            log.error("rootFolder not detected, cannot continue");
            return Optional.empty();
        }

        mailBoxDTO.setFolderRootId(rootMailFolder.get().getId());
        mailBoxDTO.setTotalItemCount(rootMailFolder.get().getTotalItemCount());

        List<MailFolder> childFolders =
            getAllChildFolders(mailBoxDTO.getMailBox(), rootMailFolder.get().getId());

        boolean archiveFound = false;
        boolean rejectFound = false;

        for (MailFolder mf : childFolders) {
            if (mf.getDisplayName().equalsIgnoreCase(mailBoxDTO.getArchiveChildPath())) {
                mailBoxDTO.setArchiveChildPathId(mf.getId());
                archiveFound = true;
            }

            if (mf.getDisplayName().equalsIgnoreCase(mailBoxDTO.getRejectChildPath())) {
                mailBoxDTO.setRejectChildPathId(mf.getId());
                rejectFound = true;
            }

            if (archiveFound && rejectFound) {
                break;
            }
        }

        Optional<MailFolder> childFolder;

        if (!archiveFound) {
            childFolder = createChildFolder(
                mailBoxDTO.getMailBox(),
                mailBoxDTO.getFolderRootId(),
                mailBoxDTO.getArchiveChildPath()
            );
            if (childFolder.isPresent()) {
                mailBoxDTO.setArchiveChildPathId(childFolder.get().getId());
            } else {
                log.error("Error: Archive Child Folder Not Created {}, {}, {}",
                    mailBoxDTO.getMailBox(),
                    mailBoxDTO.getFolderRootId(),
                    mailBoxDTO.getArchiveChildPath());
            }
        }

        if (!rejectFound) {
            childFolder = createChildFolder(
                mailBoxDTO.getMailBox(),
                mailBoxDTO.getFolderRootId(),
                mailBoxDTO.getRejectChildPath()
            );
            if (childFolder.isPresent()) {
                mailBoxDTO.setRejectChildPathId(childFolder.get().getId());
            } else {
                log.error("Error: Reject Child Folder Not Created {}, {}, {}",
                    mailBoxDTO.getMailBox(),
                    mailBoxDTO.getFolderRootId(),
                    mailBoxDTO.getRejectChildPath());
            }
        }

        return Optional.of(mailBoxDTO);

    } catch (ApiException e) {
        log.error("Erreur pour findFoldersId", e);
        throw e;
    }
}
