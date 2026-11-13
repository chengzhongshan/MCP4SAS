# Persistent archive transfers and SAS supplied autocall macros

Persistent transfer_many now sends one bulk request to the existing SASPy session server. With archive_transfers enabled (the default), two or more uploads or downloads use ZIP transfer; a single file or explicit false retains the individual-file path. The server protocol version is advanced so an older helper cannot silently accept an unsupported request. No second SAS session is opened by this implementation.

The archive implementation adapts the established SAS ZIP/ODS package workflow. It uses generated member names, checks duplicate upload basenames and duplicate local destinations, verifies extracted byte sizes, checks ZIP CRCs during extraction, stages downloads before promoting them, and cleans archive/staging files in finally blocks. Upload reuse preserves the prior size/timestamp policy. Macro-variable include checks remain deferred to SAS as in the preceding fix.

Batched metadata avoids querying each file through a SAS submit followed by four separate macro-variable retrieval calls. Cygwin/native-Windows normalization now handles nested bulk payloads, including the request condition that previously normalized only top-level local_path.

LEFT and TRIM are recognized as SAS-supplied autocall helpers and are no longer sent to the custom remote macro loader. Custom macro names, including clustergram4sas and my_left, remain dependencies. This assumes the normal SAS autocall library is configured; deliberately removing SASAUTOS is outside this change.

Tests cover the archive switch, missing sources, duplicate names/destinations, successful extraction, corruption or missing members preserving existing downloads, temp cleanup, one-submit metadata, incomplete metadata, real nested Windows/Cygwin path I/O, autocall classification and existing custom dependency parsing. Local SAS HOME regressions remain passing. Upload replacement and multiple final filesystem renames are not a cross-file transaction; failures are reported rather than claimed as complete.

Live benchmark details and failed pilot exclusions are retained in the separate MCP4SAS_POC_20261112 evaluation directory. The [performance debugging guide](PERFORMANCE_DEBUGGING.md) records the subsequent source-analysis correction, final accepted runtimes, sanitized measurement evidence and regression procedure. No new raw genomic analysis or AI token/cost benchmark is implied.
