public static boolean attachIsValid(int sizeAttachOctet, PatternFileDTO pattern, String extension) {

    // CSV toujours OK (si c’est voulu)
    if ("csv".equalsIgnoreCase(extension)) {
        return true;
    }

    // Ignorer tous les fichiers < sizeIgnored
    if (sizeAttachOctet < pattern.getSizeIgnored()) {   // ex: 1024
        return false;
    }

    // Si l'extension fait partie des extensions à contrôler (ex: png),
    // alors il faut respecter sizeChecked
    if (isInPattern(extension, pattern.getToCheckSize())) {
        return sizeAttachOctet >= pattern.getSizeChecked(); // ex: 10240
    }

    // Sinon, dès qu’on dépasse sizeIgnored, c’est OK
    return true;
}
