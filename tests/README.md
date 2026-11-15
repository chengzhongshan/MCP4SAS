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
