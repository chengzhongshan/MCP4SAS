# Python PoC execution and simplified video commands

On 15 November 2026, all six saved-program PoC cases were executed through the
Python runner against SAS OnDemand from this Windows workstation. All passed.
The independent standalone Python checker was also launched for each case.

| Case | Checks | SAS warnings | End-to-end seconds |
|---|---:|---:|---:|
| clustergram | 509 | 8 | 41.589 |
| gene_gtf | 59 | 8 | 47.208 |
| oncoprint | 33 | 2 | 28.417 |
| forest | 30 | 0 | 24.070 |
| multi_gwas_gtf | 11,295 | 5 | 90.189 |
| hello | 3 | 0 | 9.498 |
| **Total** | **11,929** | **23** | |

These times include program submission, rendering, collecting outputs and
checking results. Cases ran sequentially in one Python-owned persistent session;
the first includes its startup. They are not controlled direct-SASPy comparisons
or measurements of AI writing/debugging time, tokens or cost.

## What was checked

The source program and input hashes matched the frozen PoC manifest before
and after execution. All 49 declared output files were collected and hashed.
Checks cover file integrity, row counts, expression standardization, three
transcript identifiers, association heights, signed-LD arithmetic, the synthetic
oncoprint's assessable denominators and event totals, forest-plot log-odds
transformations, and 19 distinct SASHELP.CLASS records. The standalone checkers
repeated the same 11,929 assertions; these are not 23,858 distinct checks.

All eight PNGs were visually reviewed separately from the numerical assertions:
the clustergram, branch-review tree, transcript plot, oncoprint, frequency bars,
two forest plots and three-panel regional GWAS plot rendered. The branch-review
tree's many CL labels are crowded along its baseline; successful rendering does
not establish publication quality or resolve the earlier sequence-dependent
clustergram label problem. No original SAS figure program or input was changed.

The 23 warnings are retained in the machine-readable report and full SAS logs:
14 recursive CREATE TABLE warnings, seven large-output-size warnings, and two
no-active-output-destination warnings. They are not Python connection failures.
Their presence still requires attention when adapting these scientific examples.
The oncoprint remains a labeled synthetic demonstration, not patient findings.

Complete submitted programs, SAS logs, runtime status, console evidence, numerical
tables and figures remain locally under
`MCP4SAS_Use_Python/test-results/poc-video-20261115-r2/`.
[The tracked execution manifest](PYTHON_POC_EXECUTION_20261115.json) records
case outcomes, warnings, output hashes and dimensions. The test-owned session
was closed successfully; unrelated sessions were not targeted.

The first suite attempt failed before SAS because the new orchestration script
passed a relative configuration filename after changing its working directory.
The harness now resolves that filename before launching subprocesses. That failed
attempt remains in `test-results/poc-video-20261115/`; the successful run is the
explicit `-r2` directory. It is not hidden or counted as a successful trial.

## Verified Cygwin command without environment activation

In the author's existing, configured Windows/Cygwin installation, the following
plain command was executed without `PIPELINE_PYTHON_BIN` or manual activation:

```bash
python run_sas_codes_or_files_in_ODA.py --code 'proc print data=sashelp.class(obs=3);run;'
```

The base `/usr/bin/python` could not import SASPy. The runner discovered the
installer's `.venv-pipeline/.python-bin` record, relaunched with that compatible
Cygwin environment and completed SAS execution with exit 0, zero errors and
zero warnings. The returned HTML and log are preserved in the local video
project's `render/cygwin_autoenv_evidence/submit/` directory. PowerShell's output
wrapper classified the informational stderr relaunch notice as a NativeCommandError;
the runner's actual saved SAS status is exit 0. This was reuse of an installed
environment, not a fresh installation test. A new unconfigured source folder
still needs installation first.

The six full PoC cases above used the current repository's native Windows Python
environment. The Cygwin check establishes the simple command used in the video;
it is not a claim that all six cases were rerun on macOS, Ubuntu or Cygwin.

## Repeat the suite

After installing/configuring the Python edition, run from the repository root:

```bash
python tests/run_python_poc_suite.py --outdir PATH_TO_NEW_RESULTS
python tests/run_python_poc_suite.py --live --outdir PATH_TO_NEW_RESULTS
```

The first command only verifies frozen source hashes and lists the plan. The
second makes real SAS submissions. Use a new output directory; optional
`--saspy-cfgname` and `--saspy-cfgfile` select an existing private configuration.
Run this developer harness with a Python environment that has SASPy installed.
For individual demonstrations, the ordinary `examples/poc/run_example.py`
command delegates submission to the runner, which can discover that environment.
