# Live SAS ODA acceptance — 23 November 2026

Both repositories completed the live checks with their Perl and Python runners. Every accepted SAS submission exited successfully, produced its required results, and passed the independent numerical checks.

| Repository | Plot-run baseline revision | Perl | Python |
|---|---|---|---|
| MCP4SAS | `3098227cda343e4fec1e0342afb8bd88c80b1118` | PASS | PASS |
| MultiGWAS-Explorer | `aa5ba83c1d50c1af21448226089ce66f939e689d` | PASS | PASS |

The final-state file-operation fix was executed in the follow-up probes and committed as mcp: `66774f8efe39d5c206799559b292a9deaccd6fba`, explorer: `55357a24d330b2e7aeccfdb1fa9307d3353ca9e7`.

The installed VS Code MCP4SAS tool also returned three SASHELP.CLASS rows as HTML (exit 0, no warnings).

## What actually ran

- SASHELP.CLASS HTML and WORK.A creation; implicit and explicit PRINT both returned 19 rows from the unchanged SAS PID.
- A large submitted source file, exercising source staging.
- Two-file upload, SAS calculation (two rows, sum 33), download and SHA-256 byte equality.
- Nested local include and macro discovery; GTEx macro-query HTML.
- Four retained plotting programs per runner: forest, 40-gene clustergram, synthetic mutation oncoprint and multi-GWAS regional/GTF visualization.
- Collection of all required PNG/SVG/CSV files, followed by exact removal and absence checks for test-owned HOME inputs. Existing user sessions and inputs were preserved.

| Repository / runner | GTEx macros | Plot checks | Remote inputs removed |
|---|---:|---:|---:|
| MCP4SAS / perl | 14 | 11,867 | 7 |
| MCP4SAS / python | 14 | 11,867 | 7 |
| MultiGWAS-Explorer / perl | 14 | 11,867 | 7 |
| MultiGWAS-Explorer / python | 14 | 11,867 | 7 |

Total independent file, row-count and numerical checks: **47,468**. Separately, **72** CSV comparisons matched the MCP4SAS Perl reference at relative tolerance `1e-10` (exact equality for text).

Rendered appearance was compared separately: 21/21 PNG comparisons were pixel-identical. See the JSON for every comparison.

## Issues found and resolved

The first test helper was named VERIFY and shadowed the SAS-supplied %VERIFY autocall used by %LEFT. The failed logs remain local. Only the test helper was renamed to a unique session-prefixed name; plotting programs were preserved and fresh sessions rerun.

Python inspected files before deleting them in a combined request. Both native CLIs now match Perl: download, delete, then final listing/metadata. Three offline regressions and a new live combined-operation probe in each repository passed. The follow-up independently verified all seven earlier inputs absent, downloaded a new file before deletion, preserved an unselected file, and cleaned all three new inputs. Original failed acceptance.json files remain unchanged; only this derived summary resolves the cleanup assertion. Graphics were not rerun after this file-operation-only fix.

The retained programs produce warnings about large graphic dimensions, recursive SQL CREATE TABLE references and an intermediate inactive output destination. The final renders and numerical checks passed. These warnings are disclosed rather than relabeled as failures or suppressed.

## Evidence and scope

The full source, logs and downloaded artifacts below are retained locally in ignored `SAS_Output` directories. The committed JSON contains the execution manifest, checks and output hashes. The gallery includes hash-verified preview copies so that its images remain available from a clean checkout.

- [MCP4SAS: complete source, logs, timings and artifacts](../SAS_Output_RandID_oda_acceptance_20261123_1795462909325/acceptance.json)
- [MultiGWAS-Explorer: complete source, logs, timings and artifacts](../../MultiGWAS-Explorer-git/MultiGWAS-Explorer/SAS_Output_RandID_oda_acceptance_20261123_1795462909305/acceptance.json)
- [MCP4SAS: actual post-fix file-operation checks](../SAS_Output_RandID_oda_fileops_20261123_1795463707322/followup.json)
- [MultiGWAS-Explorer: actual post-fix file-operation checks](../../MultiGWAS-Explorer-git/MultiGWAS-Explorer/SAS_Output_RandID_oda_fileops_20261123_1795463717572/followup.json)
- [Visual gallery](LIVE_ODA_GALLERY_20261123.html)

- Four frozen PoC programs, not a full study/preprocessing/LD/GTF-download pipeline rerun.
- Prepared GTEx/PGC summaries; oncoprint events are synthetic.
- This live run used Windows/Cygwin and native Windows Python clients; the SAS execution host was ODA Linux.
- SAS warnings were retained, not silently removed.
- Concurrent elapsed times are observations, not a controlled runtime or cost benchmark.
- The frozen forest plot has a very tight left variant-label margin. Successful execution does not certify publication layout.

## Additional offline regression results

- New combined-operation regression: 3/3 tests passed in each repository.
- MCP4SAS native Python unit suite: 93 tests, 91 passed and 2 skipped because the selected Anaconda interpreter lacks the optional Python MCP SDK. These skipped transports are not claimed as tested. The installed VS Code MCP tool was tested separately against ODA.
- MultiGWAS-Explorer adapted runtime manifest: 43 current file hashes verified.
- MultiGWAS-Explorer `install/check_sas_runtime.sh`: exit 0, including Perl regressions, native Python boundary checks, macro bootstrap and the new combined-operation regression. The existing Java-help test emits a Perl variable-shadowing warning.
- Real Cygwin-to-native Python handoff was then explicitly enabled and tested separately: 8/8 passed in each repository, including space-containing paths and quoted SAS source. This is a client-boundary test without a SAS submission.
- All live CLI tests retained HTML/figures without launching browser windows (`--no-open-html`). This run verifies generated files, not automatic browser launch.


## Quick smoke commands

Run from the repository directory using the already configured private SASPy environment.

```bash
perl run_sas_codes_or_files_in_ODA.pl --saspy-cfgname oda --code 'proc print data=sashelp.class;run;' --open-html
python run_sas_codes_or_files_in_ODA.py --saspy-cfgname oda --code 'proc print data=sashelp.class;run;' --open-html
```
