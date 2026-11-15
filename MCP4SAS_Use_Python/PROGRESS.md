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
this does not mean all 590 were executed. All six cross-platform jobs passed in
run 43660360756 at code commit 21bc495; the completed update is published to main.
See HOMEPAGE_DEMO_VALIDATION.md for the exact scope, fixes and evidence limits.

## Author's Copilot-fix review

Branch fix/copilot-runner-review compares 16 edited files from the author's local
test installation with baseline b7e3f7e. The source installation is unchanged.
Reviewed fixes include environment handoff, separate HTML output, browser controls,
macro-directory fallback, network-path diagnostics and owned timeout cleanup.
Unsafe implicit escape conversion, unanchored error matching and extra normal
shutdown waits were corrected. Native Windows validation passed 64 Python tests,
91 Perl assertions and ten live SAS ODA operations. All six Python jobs passed
in run 43677593186, and all three Perl jobs passed in run 43677287994. The fixes
are integrated into local/main and GitHub/main. See
docs/COPILOT_RUNNER_FIX_REVIEW.md at repository root.

## Complete root test review — November 15, 2026

All 80 root Perl test/catalog scripts now have Python counterparts. The final
combined offline run passed 116 scripts, and the existing Python package suite
passed 64 tests. Actual ODA execution and independent saved-evidence auditing
verified 4,550 numerical cases and 590 MCP examples for each runtime after
explicit, recorded reruns. Runtime fixes cover quoted single-file uploads,
deferred path escaping, preflight status, raised session-loss classification,
owned dead-bridge cleanup and runtime-only expected-error validation. Case 240's
expected note was corrected without changing its SAS body. All 590 example
bodies remain preserved. See `docs/COMPLETE_TEST_REPORT.md`, its machine-readable
manifest, and `docs/TEST_SCRIPT_EXECUTION.csv` for complete scope and limitations.
