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
macOS filename-case issue is fixed; the final six-job matrix passed at code commit
458bb485c5792182c7a846f82088c5938079c907 (run 43657296733), with all 30 tests on
each platform/Python combination. The agreed runtime-and-utilities scope is complete.
The subsequent homepage update publishes this optional Python edition on main
with a dual-runtime workflow diagram and runnable commands. The Perl runtime,
existing plugin and book are unchanged. Pre-existing local changes in
MCPDeps/sas_oda_session_server.py and debug.log were not included.

No claim of complete Perl compatibility or live platform validation is made until
the corresponding evidence is recorded.

## Homepage demo follow-up

The author subsequently requested Python counterparts for all Perl scripts named
on the homepage. All 19 scripts in the main and linked README guides now have
Python counterparts, with 44 paired command blocks. The scope includes 17 newly
implemented developer/demo sources (32 implemented / 82 deferred in the inventory).
The 43-test local suite and six selected live SAS ODA cases passed. All 590
original SAS examples were generated and checked for unchanged source/fixtures;
this does not mean all 590 were executed. Cross-platform branch CI is pending.
See HOMEPAGE_DEMO_VALIDATION.md for the exact scope, fixes and evidence limits.
