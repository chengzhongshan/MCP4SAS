# Python counterparts for the GitHub demos

The homepage and linked showcase/setup guides offer Perl and Python alternatives.
Choose one runtime; do not execute both versions of a destructive operation.
Install and activate the [Python environment](../MCP4SAS_Use_Python/README.md#install-in-a-separate-python-environment)
before using the commands below. Python needs no Perl or Cygwin.

## Script map

All 19 distinct Perl scripts named on the homepage and its linked README guides
have these Python counterparts. Runners keep the same SAS inputs. Developer
checks test Python behavior; they do not claim to exercise Perl internals.

| Perl entry point | Python counterpart | Purpose |
|---|---|---|
| `server.pl` | [`server.py`](../server.py) | MCP jobs, polling and diagnostics |
| `run_sas_codes_or_files_in_ODA.pl` | [`run_sas_codes_or_files_in_ODA.py`](../run_sas_codes_or_files_in_ODA.py) | SAS submission and file operations |
| `cleanup_mcp4sas_intermediates.pl` | [`cleanup_mcp4sas_intermediates.py`](../cleanup_mcp4sas_intermediates.py) | Preview/remove verified inactive scratch |
| `examples/poc/run_example.pl` | [`examples/poc/run_example.py`](../examples/poc/run_example.py) | Six original saved-program examples |
| `examples/poc/validate_outputs.pl` | [`examples/poc/validate_outputs.py`](../examples/poc/validate_outputs.py) | Independent numerical/file checks |
| `tools/profile_sas_source.pl` | [`tools/profile_sas_source.py`](../tools/profile_sas_source.py) | Offline parser timings and result hashes |
| `MCPDeps/test_sas_log_and_labels.pl` | [`MCPDeps/test_sas_log_and_labels.py`](../MCPDeps/test_sas_log_and_labels.py) | Runtime errors, source echoes and macro labels |
| `MCPDeps/test_sas_oda_debug_macro_guard.pl` | [`MCPDeps/test_sas_oda_debug_macro_guard.py`](../MCPDeps/test_sas_oda_debug_macro_guard.py) | Bootstrap names and failed/successful caching |
| `MCPDeps/test_sas_oda_connection_lifecycle.pl` | [`MCPDeps/test_sas_oda_connection_lifecycle.py`](../MCPDeps/test_sas_oda_connection_lifecycle.py) | Real Python backend startup, reuse and closure |
| `MCPDeps/test_sas_oda_include_lookup.pl` | [`MCPDeps/test_sas_oda_include_lookup.py`](../MCPDeps/test_sas_oda_include_lookup.py) | Local bundled macro lookup |
| `MCPDeps/test_sas_oda_macro_helper_reuse.pl` | [`MCPDeps/test_sas_oda_macro_helper_reuse.py`](../MCPDeps/test_sas_oda_macro_helper_reuse.py) | Avoid resubmitting a verified bootstrap |
| `tests/new_validation_tasks_001_100.pl` | [`tests/new_validation_tasks_001_100.py`](../tests/new_validation_tasks_001_100.py) | 100 offline adversarial contracts |
| `tests/covid19_gwas_validation_tasks_001_500.pl` | [`tests/covid19_gwas_validation_tasks_001_500.py`](../tests/covid19_gwas_validation_tasks_001_500.py) | 500 pinned macro-source checks |
| `tools/build_covid19_validation_corpus.pl` | [`tools/build_covid19_validation_corpus.py`](../tools/build_covid19_validation_corpus.py) | Build a new source-versioned corpus |
| `tests/run_live_new_examples_30.pl` | [`tests/run_live_new_examples_30.py`](../tests/run_live_new_examples_30.py) | Generate/run any of eight original batches |
| `tests/new_examples_31_60.pl` | [`tests/new_examples_31_60.py`](../tests/new_examples_31_60.py) | Inspect/export batch 2 |
| `tests/new_examples_61_90.pl` | [`tests/new_examples_61_90.py`](../tests/new_examples_61_90.py) | Inspect/export batch 3 |
| `tests/new_examples_191_290.pl` | [`tests/new_examples_191_290.py`](../tests/new_examples_191_290.py) | Inspect/export batch 5 |
| `tests/run_live_examples.pl` | [`tests/run_live_examples.py`](../tests/run_live_examples.py) | Beginner SAS and public GTEx API cases |

Batch catalogs 4, 6, 7 and 8 also have adjacent `.py` entry points. Other developer
scripts remain listed as deferred in the [port inventory](../MCP4SAS_Use_Python/PORT_INVENTORY.csv).

## Generate examples without SAS

```bash
python tests/run_live_new_examples_30.py --generate-only --batch 1 --out ./python_batch1
python tests/run_live_new_examples_30.py --generate-only --batch 8 --out ./python_batch8
python tests/new_examples_31_60.py --out ./python_batch2
python tests/new_validation_tasks_001_100.py
python tests/covid19_gwas_validation_tasks_001_500.py
```

Use new output directories. The catalogs preserve all 590 SAS programs, expected
results and fixture bodies from the original Perl catalogs. Generation rewrites
only fixture placeholders to newly created local files. Source hashes identify
the original catalogs; no Perl interpreter is used when generating examples.

To rebuild the 500-task corpus from a local Git checkout, choose the recorded
source revision explicitly and write a new manifest:

```bash
python tools/build_covid19_validation_corpus.py /path/to/COVID19_GWAS_Analyzer ./new_corpus.json --source-commit 4fa6fa710b8506b4aa410c0dfed304d447e41c8a
python tests/covid19_gwas_validation_tasks_001_500.py --manifest ./new_corpus.json
```

The Python builder reads Git objects at that revision, rather than silently
including working-tree edits. It refuses to overwrite an existing output file.

## Explicit live execution

Generation does not submit SAS. After configuring your SAS account, execute two
selected original cases through a Python MCP stdio server:

```bash
python tests/run_live_new_examples_30.py --live --only 01,02 --out ./python_live_pair
```

Case 01 must produce a checked join result; case 02 must fail because its
transpose identifiers are duplicated. A correct expected failure passes the
test while retaining the SAS error. Complete logs and MCP responses remain in
the output directory. Failures are retained and never automatically replayed.

For an already running Python HTTP server:

```bash
python server.py daemon --host 127.0.0.1 --port 8081
# In a second terminal with the same environment:
python tests/run_live_new_examples_30.py --live --only 01,02 --url http://127.0.0.1:8081/mcp --out ./python_http_pair
```

For the existing Perl HTTP server, add `--legacy-http` and use its port, for
example `--url http://127.0.0.1:8080/mcp`. This targets the Perl tool deliberately;
the default Python stdio route does not launch Perl. A server used for these
checks must share the local filesystem so the harness can inspect full logs.

The beginner CLI suite is separate:

```bash
python tests/run_live_examples.py --live --only basic_summary macro_control_flow expected_missing_table
```

Without `--only`, it also requests the public GTEx API from SAS. The API/network
and returned scientific records require their own live checks. Offline CI does
not claim to have run all 590 SAS cases or queried GTEx.

## Native Windows PowerShell

After the separate Python setup, run native Windows SAS COM without Cygwin:

```powershell
./MCP4SAS_Use_Python/.venv/Scripts/Activate.ps1
python run_sas_codes_or_files_in_ODA.py --saspy-cfgname winlocal_com --saspy-cfgfile install/sascfg_windows_local_com.py --code 'proc print data=sashelp.class; run;'
```

For SAS ODA, choose `--saspy-cfgname oda` and use its configured Java, licensed
encryption JARs and private account. The [Python setup guide](../MCP4SAS_Use_Python/README.md)
explains detection and credential setup. The existing plugin remains version
0.1.5 and continues to configure its Perl runtime.

Python and Perl use separate session registries. Python file-deletion regexes
skip directories, and its kill command closes only the selected Python session.
Other compatibility differences are recorded in the Python guide.
