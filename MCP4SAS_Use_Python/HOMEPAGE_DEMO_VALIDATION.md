# Homepage Python demo validation

This follow-up extends the initial runtime/utility port to the Perl scripts
named on the main homepage and four linked README guides. It does not port all
historical developer scripts. The inventory now records 32 implemented sources
and 82 deferred sources.

## Documentation and source coverage

- All 19 distinct `.pl` scripts referenced in the five README guides have an
  adjacent `.py` counterpart. This includes 17 newly implemented developer/demo
  entry points; some support catalogs are also needed by the eight-batch harness.
- 44 code blocks now have an expandable Python alternative. Native Windows
  PowerShell and transport/configuration differences are explained separately.
- The saved-program PoC runner and validator keep the original SAS programs,
  datasets and scientific evidence labels unchanged.
- The eight catalogs contain 590 original SAS examples. Their Perl source hashes
  and exact SAS/fixture bodies are saved in `assets/example_catalogs.json`.
  Perl is required only for the maintainer's one-time snapshot rebuild, not for
  Python catalog generation, regression checks or live execution.
- The new corpus builder reads a requested Git revision, refuses to overwrite
  an output, and records that source revision. Its behavior was tested against a
  temporary Git repository containing 500 source-derived checks and an altered
  working file, proving that it reads committed objects rather than local edits.

## Actual offline results

The complete native Windows suite passed **43 tests**. These include the existing
real backend/MCP transport tests, the 100 adversarial contracts, the original
500-task COVID19 macro corpus, exact reconstruction of all 590 generated SAS
programs/fixtures, source-hash verification, entry-point coverage, documentation
link checks and parsing of the documented Python runner options.

The old Perl lifecycle/bootstrap tests inspect Perl implementation details. Their
Python counterparts test Python behavior: authenticated backend processes,
session reuse/closure, bootstrap caching, macro-name bounds, local dependency
resolution and runtime diagnostics. They do not claim identical internal output.
On Windows accounts without symlink privilege, the symlink guard is exercised
with a mocked filesystem capability; macOS/Linux CI can additionally create the
real symlink.

## Actual SAS ODA results

The new native Python harnesses executed these unchanged original programs:

| Harness | Case | Observed result |
|---|---|---|
| Actual MCP stdio | 01, SQL join cardinality | COMPLETE, exit 0, independently required runtime result marker |
| Actual MCP stdio | 02, duplicate transpose ID | FAILED, exit 1, expected SAS diagnostic and MCP error flag |
| Actual MCP stdio | 491, two quoted include files | COMPLETE, exit 0, computed marker, zero warnings/data-quality diagnostics |
| Beginner CLI | basic_summary | Exit 0, successful status JSON and nonempty HTML |
| Beginner CLI | macro_control_flow | Exit 0, successful status JSON and nonempty HTML |
| Beginner CLI | expected_missing_table | Exit 1, failed status JSON and expected SAS error |

Case 491 uploaded both generated include fixtures; the remote cleanup submission
and session closure completed successfully. Logs, complete submitted code and
MCP responses remain in the ignored `test-results/homepage-*-live/` directories.
The machine-readable summary records hashes and results without private account
configuration or paths.

These are six selected live cases. All 590 cases were generated and checked for
source preservation; they were **not** all executed in SAS. The GTEx API branch,
the new harness's optional HTTP/legacy-Perl transport selection, and live SAS on
macOS/Linux were not exercised in this follow-up. Existing SDK stdio/HTTP server
tests remain part of the offline suite. No speed, token or cost claim is made.

## Defects exposed and corrected

1. A cleanup ownership marker containing a JSON array could raise `AttributeError`
   instead of being rejected. Inspection now rejects non-object markers and
   boolean PID/timestamp values; it preserves unowned files.
2. Includes using `~/Macro.sas` did not check bundled `MCPDeps`/`DiffGWASDeps`
   sources. Bounded local lookup now stages the existing file without recursively
   searching the workspace or altering its source.
3. An unresolved-macro warning on its own could be classified as success. The
   Python classifier now returns a nonzero macro-resolution failure, while
   source echoes and ordinary warnings retain their previous behavior.

The Perl scripts, original SAS programs and VS Code plugin implementation are
unchanged. Pre-existing local backend whitespace edits and `debug.log` are excluded.

## Cross-platform checkpoint

The six-job Python matrix installs dependencies, runs the offline suite and
executes the new regression/generation entry points on Windows, macOS and Ubuntu
with Python 3.10 and 3.13. All six jobs passed in
[run 43660360756](https://github.com/chengzhongshan/MCP4SAS/actions/runs/43660360756)
at code commit `21bc49584627a217dbc830dbd629aa399396d241`, including all 43 tests
and the additional standalone entry-point checks. Subsequent documentation-only
corrections clarify environment setup and the distinct default PoC session names;
the documentation link/option check was rerun successfully after those edits.
