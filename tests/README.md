# Runner regression tests

Run commands from the repository root with the Python environment described in
`MCP4SAS_Use_Python/README.md`. The Python runner and its test counterparts do not
invoke Perl. Some maintainer orchestrators deliberately launch the original Perl
tests when explicitly selecting that runtime.

## Offline checks

```bash
python -m unittest discover -s MCP4SAS_Use_Python/tests -v
python tests/run_complete_suite.py --language python
```

For both runtimes, supply the installed Perl and Bash executables if necessary:

```bash
python tests/run_complete_suite.py --perl perl --bash bash
```

Windows can use an absolute Cygwin Perl/Bash path. The suite and Git sync test
prefer Git Bash to the Windows WSL launcher when no Bash is explicitly selected.
Each script has its own log, return code, elapsed time, source hash and status in
`MCP4SAS_Use_Python/test-results/complete-suite/coverage.json`. A nonzero exit,
failed TAP assertion or timeout fails the suite. A script not selected for
execution remains `not_run`; it is not promoted to passing evidence.

## Actual SAS execution

These commands use your configured SAS account. Review the fixtures before using
them against a different target. Credentials stay in private SASPy configuration
and auth files, never in the command or the committed test artifacts.

```bash
python tests/run_live_library500.py --live --round 1
python tests/run_live_library500.py --live --round 8 --only J3501,J3951
python tests/run_live_macro_open_code50.py --live --raw
python tests/test_live_deferred_includes.py --live
python tests/run_live_mcp_examples.py --live
python tests/run_live_cli_cleanup.py --live
python tests/run_example_catalog_suite.py --runtime python --live --out MCP4SAS_Use_Python/test-results/my-python-catalogs
```

The numerical collections contain 500 cases in rounds 1–8 and 10, and 50 cases
in round 9: **4,550 cases total**. Positive cases may share a batch; intentional
SAS errors execute separately. Source and oracle hashes, full submitted programs,
full logs, terminal status and results are retained. The named Python session is
closed in a finalizer. `--raw` explicitly bypasses structural preflight so the
50-case test measures SAS compiler/runtime behavior; ordinary submissions retain
the default guard. The eight additional MCP example catalogs contain 590 cases
and are distinct from those numerical collections.

Use an unused output directory. Test outputs are ignored by Git. To verify saved
evidence independently of a harness's recorded pass flag:

```bash
python tools/collect_library_evaluation_results.py --round 1 --run YOUR_RUN_DIRECTORY --output YOUR_AUDIT.json
```

Only evidence under the owned repository test-output locations is accepted. The
collector checks source text, case and oracle hashes, runtime-only markers and
terminal status. `--skip-stale` explicitly excludes changed contracts, records
them as excluded, and cannot turn an incomplete collection into a complete one.

## What a counterpart means

For the extension's target-switching regressions, live Windows/ODA examples
and Linux configuration coverage, see [VSCODE_SAS_SWITCHING.md](VSCODE_SAS_SWITCHING.md).

The `.py` files beside the original `.pl` tests use three approaches:

- Native functional tests exercise the public Python CLI/MCP interfaces.
- Numerical tests reuse the original SAS programs and reviewed oracle manifests.
- Source-analysis tests replay hash-pinned Perl API inputs against Python. These
  are differential compatibility checks, not independent proof that a parser or
  scientific calculation is correct. Focused entry points reuse native unit tests
  where the relevant behavior is already tested; Perl-only implementation details
  are not invented for Python.

`MCP4SAS_Use_Python/tests/build_remaining_fixtures.py` is a maintainer-only Perl
reference exporter. It snapshots values when calls return so later cache mutation
cannot corrupt the comparison. Published regression entry points read its JSON
fixtures without launching Perl.

Offline fake-SAS and COM ownership tests do not establish that licensed local SAS
works on macOS, Linux or Windows. Live ODA results and cross-platform CI results
must be reported separately.

## Run every Python PoC example

The opt-in `run_python_poc_suite.py` executes all six frozen PoC programs,
collects their figures/tables, verifies source hashes, invokes numerical checks,
and closes only its own session, including after a failure. Use a configured
Python environment with SASPy and a new output directory:

```bash
python tests/run_python_poc_suite.py --outdir PATH_TO_NEW_RESULTS
python tests/run_python_poc_suite.py --live --outdir PATH_TO_NEW_RESULTS
```

Without `--live`, only source checks and the execution plan run. See the
[15 November execution report](../docs/PYTHON_POC_VALIDATION_20261115.md) for
actual outcomes, retained warnings and limits of the graphical checks.


## Discover GTEx macros and regress macroparas

`test_macroparas_gtex.py` checks the portable source/dependency plan offline.
`test_macroparas_gtex.pl` checks the Perl-facing utility contract. Their live
mode executes `macroparas_gtex_regression.sas` through the chosen real runner;
it creates only WORK fixtures and does not run the inspected GTEx analyses.

```bash
python tests/test_macroparas_gtex.py
perl tests/test_macroparas_gtex.pl
python tests/test_macroparas_gtex.py --live --runner both --perl /path/to/perl --saspy-cfgname oda --saspy-cfgfile /path/to/sascfg_personal.py
```

See [the 20-macro catalog, bug history and actual Windows/ODA results](../docs/GTEX_MACRO_CATALOG.md).
The portable repair is `examples/sas_macros/macroparas_portable.sas`.
`test_persistent_archive.py` also guards bounded upload-verification retries;
these retries never replay submitted user SAS code.


## Beta macro parameter wiring and nested includes

`beta_macro_regression.sas` generates 240 synthetic count observations from 60
subjects. It compares a custom-column fit with a renamed-column fit and checks
convergence, custom outputs, predictions and preservation of the caller's table.
`beta_macro_invalid_inputs.sas` checks missing inputs/predictors, invalid counts,
clearing stale results, and rejection of an output that aliases its input.

```bash
python tests/test_beta_macros.py
perl tests/test_beta_macros.pl
python tests/test_nested_include_graph.py
perl tests/test_nested_include_graph.pl
python tests/test_beta_macros.py --live --guards --runner both --perl /path/to/perl --saspy-cfgname oda --saspy-cfgfile /path/to/sascfg_personal.py
```

The first four commands need no SAS login. Live guard cases intentionally return
exit 1 with a specific validation diagnostic; the harness verifies that both the
error and the safe postcondition are correct. Synthetic model fits do not validate
research conclusions. See [the Beta repair report](../docs/BETA_MACRO_REVIEW.md).

## MCP completion latency and safe fallback

`perl tests/test_mcp_job_reporting.pl` executes short CLI workers offline and
checks bounded completion, immediate background mode, exit/error preservation,
full-log retention and excerpting. Native equivalents are in
`MCP4SAS_Use_Python/tests/test_job_wait.py` and `test_server.py` (actual SDK stdio
and HTTP). `integrations/vscode/test/relay-recovery.test.js` exercises startup
failure and an accepted request whose reply times out, requiring no replay.

`benchmark_plugin_routes.py` is an explicitly opt-in live test for the actual
VS Code relay, direct Perl and direct Python runners. It checks known SASHELP
results, real SAS errors and asynchronous completion; it never measures model
tokens. See [instructions and retained timings](../docs/VSCODE_RUNNER_PERFORMANCE.md).
