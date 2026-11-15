# Python runtime migration

Baseline: `796c37b39e5c3017493de227b244413f8e684141`.
Branch: `feature/python-port`. The Perl runtime and unrelated working files are protected.

Approved scope: runtime and utilities first. Developer-only corpus generators and
legacy test harnesses are inventoried for later migration, not represented as ported.

Layout: implementation in `MCP4SAS_Use_Python`; Python entry points beside Perl
counterparts. Python runtime entry points must not execute Perl. Existing Python
SASPy/ZIP backend code may be reused with exact provenance.

Implemented: source inventory, source analysis, diagnostics, dependency resolution,
SASPy transport, CLI, MCP server, cleanup, profiling, expression subsetting and PoC
utilities. Root, tools and examples/poc Python launchers are beside Perl counterparts.

Observed: 30 offline tests passed, including 308 original-Perl lexical comparisons,
5 diagnostic references and 2 exact cleanup-program comparisons. Actual stdio and
Streamable HTTP MCP clients passed discovery, background completion, failure and
unknown-PID checks. Native Windows SAS ODA passed positive/negative, recursive local
macros, ZIP transfers, recovery, PRINTTO guard, timeout and restart checks.

All six original PoC examples executed through Python and passed 11,929 numerical,
file and row-count checks. Original graphics/table-recursion warnings remain logged.
Private logs and outputs are under test-results/oda-native-python-v3/ (Git-ignored).

Native Windows SAS COM and direct SAS executable checks passed. Actual Python MCP
stdio/SAS ODA calls passed positive and negative completion reporting. The initial
macOS filename-case issue is fixed; the six-job matrix passed at code commit
dd9fba6 (run 43656356598). Final report/cleanup-guard changes are pending one final
branch CI run and Git review. Main, the Perl runtime, existing plugin and book are unchanged.

No claim of complete Perl compatibility or live platform validation is made until
the corresponding evidence is recorded.
