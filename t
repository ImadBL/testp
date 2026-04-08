---
    private static final DateTimeFormatter FORMATTER =
            DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS");

    public static String generate() {
        String datePart = LocalDateTime.now().format(FORMATTER); // 17 caractères
        String randomPart = String.format("%08X", ThreadLocalRandom.current().nextInt());
        String randomPart2 = String.format("%04X", ThreadLocalRandom.current().nextInt(0, 65536));
        String randomPart3 = String.format("%04X", ThreadLocalRandom.current().nextInt(0, 65536));

        return datePart + "-" + randomPart + "-" + randomPart2 + "-" + randomPart3;
    }
