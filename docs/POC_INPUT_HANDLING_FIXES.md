# Evaluation input handling fixes

The 12 November 2026 MCP4SAS proof-of-concept comparison exposed a warning when server.pl attempted -f on multiline SAS source and avoidable local include searches for paths containing unresolved SAS macro variables. The filename guard avoids stat on multiline, NUL-containing and oversized input. Runtime-resolved include targets are deferred to SAS without local scan or attempted remote download. Literal paths remain on the existing preflight path. This conservative rule also defers literal ampersands; it does not suppress SAS execution or claim to validate dynamic dependencies.

Validation: 9 new boundary assertions; existing log diagnostics 12, deferred include paths 11, include source order 4; server and runner syntax checks pass. A live MCP job returned FAILED for a nonexistent PRINT variable; a subsequent corrected PRINT returned COMPLETE in the same session. The separate evaluation package preserves the original four-family timing and numerical/pixel equivalence record. No general performance improvement or model token/cost saving is established by these fixes.

For the later measured transfer and source-analysis corrections, see
[Performance debugging](PERFORMANCE_DEBUGGING.md). The scope of this early
input-handling test should not be confused with that later timing comparison.
