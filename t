---

file-import      → indépendant
case-discovery   → indépendant
archive          → indépendant

purge-cycle
   ↓
init report
   ↓
release archived SDO/CONTRACT → READY
   ↓
file purge
   ↓
TBC discovery + purge
   ↓
finalize report + clean



FILE IMPORT
cron.file-import
     ↓
FileImportJob


CASE DISCOVERY
cron.case-discovery
     ↓
CaseDiscoveryJob
     ↓
SDO / CONTRACT
     ↓
ArchiveCase PENDING


ARCHIVE
cron.archive
     ↓
ArchiveJob
     ↓
ArchiveCase ARCHIVED


PURGE
cron.purge-cycle
     ↓
PurgeReportInitJob
     ↓
FilePurgeJob
     │
     ├─ releaseArchivedCases()
     └─ purge READY SDO / CONTRACT
     ↓
TbcPurgeJob
     │
     ├─ discovery TBC
     └─ purge TBC
     ↓
PurgeReportFinalizeJob
     │
     ├─ compte PURGED
     ├─ compte ERROR_FINAL
     ├─ END_TIME
     └─ delete RetentionCase PURGED
