# PoC graphics rerun with Perl and Python — 21 November 2026

The source checkout was fast-forwarded from `1db5cc2` to GitHub revision `45501a491da1ae080df254bd1a4447dc57cb8858` and synchronized with the installed Windows project. Private SAS configuration, VS Code settings and credentials were preserved. The installed extension already matched the newer source. The evaluation used SAS ODA explicitly and did not switch the user's selected VS Code target.

All six examples passed through each runner: **12 successful executions**. The frozen source/input hashes matched before and after execution. Each route completed **11,929** numerical/file assertions. Repeating checks for the second runner validates a separate execution, not additional scientific methods.

| Case | Perl checks | Python checks | Perl / Python warnings | Perl seconds | Python seconds |
|---|---:|---:|---:|---:|---:|
| clustergram | 509 | 509 | 8 / 8 | 56.39 | 44.269 |
| gene_gtf | 59 | 59 | 8 / 8 | 96.312 | 47.951 |
| oncoprint | 33 | 33 | 2 / 2 | 35.709 | 28.778 |
| forest | 30 | 30 | 0 / 0 | 56.543 | 24.699 |
| multi_gwas_gtf | 11295 | 11295 | 5 / 5 | 449.186 | 90.294 |
| hello | 3 | 3 | 0 / 0 | 13.799 | 9.833 |

## Output comparison

All 30 numerical CSV tables agreed in row/column order, text and finite numeric values (relative/absolute tolerance 1e-10). Decoded RGBA pixels were identical for 8 of 8 PNG figures. PNG pixel equality is checked separately from numeric values; SVG byte differences can reflect generated identifiers and are not interpreted as scientific differences. All declared PNG/SVG/CSV outputs were collected and hashed in the [execution record](validation/poc-both-runners-20261121.json).

The local side-by-side gallery is `SAS_Output_poc_both_20261121/gallery.html`. Each case directory contains collected figures/tables, the complete SAS log, runner output and status records. Original source programs remain under `examples/poc/programs/`. No original plotting program, input, PoC document or scientific macro was rewritten.

## Warnings and scope

Each route retained its SAS warnings. These are existing recursive CREATE TABLE, oversized graphics and no-active-output-destination warnings; a successful run does not resolve them. The branch-review tree remains crowded along the baseline, and this rerun does not establish publication readiness or resolve all earlier sequence-dependent label issues. The oncoprint uses synthetic teaching events. Other scientific cases use prepared study summaries, not newly analyzed raw cohorts.

Times include orchestration, rendering, transfers and validation. The routes ran sequentially, not in a randomized repeated performance experiment; no general speed advantage, AI token savings or cost savings is inferred.

## Regression correction and cleanup

The broader Python suite initially found a Windows HTTP test cleanup failure: terminating only a virtual-environment launcher left its child holding the test log open. Commit `d509117` changes that test to stop only its owned process tree. All **93 Python tests** then passed. The correction does not change submitted SAS or plotting logic. The failed regression log is retained alongside the successful one.

The Perl evaluation explicitly ended its own SAS session and shut down its dedicated local server. Its END-SAS command can return a connection-termination exit because termination is intentional. The Python evaluation closed its selected session normally. No global Perl process-kill option or unrelated-session cleanup was used.

## Large-file Perl preflight correction

The initial Perl multi-GWAS execution took 449.186 seconds. Inspection found a macro-invocation scanner that copied the entire remaining source string at every character. Both compatibility entry points now scan at the current string position without those quadratic copies. Nested calls, whitespace, comment/quote masking, missing-parenthesis diagnostics and source line numbers are preserved; preflight is still enabled. The frozen 816,114-byte program's 758 invocation spans were scanned in 3.209 seconds in a standalone local measurement.

A separate fresh-session repeat completed in 152.501 seconds and passed all 11,295 checks. Every CSV and decoded PNG matched the initial execution; SVG identifiers can vary. This repeat overlapped the independent Python suite and is a single observation, not a controlled estimate of general speedup. Both the slow original and the optimized repeat remain in local evidence. `tests/test_macro_span_scaling.pl` preserves the large-prefix and nested-call regression cases in CI.

The Windows test-cleanup correction also required the Unix HTTP fixture to start in its own process group. That platform correction is in commit `8f89bb3`; its Python runtime and installation workflows both passed.
