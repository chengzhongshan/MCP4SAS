# Diagnosing slow MCP4SAS submissions

Measure where a request spends its time before changing the SAS program. In the
12 November 2026 evaluation, the regional and forest requests took about 60–68
seconds even though their session-server `submit` calls returned in about 5–6
seconds. The largest remaining delay was local source inspection, not the plot.
This guide records the investigation, the fixes, and the checks that protect them.

## What changed

| Symptom | Evidence and cause | Correction and regression protection |
|---|---|---|
| Filename warnings for submitted SAS text | `server.pl` applied a file-existence probe to multiline, NUL-containing or oversized source | Guard the filename probe. `tests/test_poc_input_boundaries.pl` preserves file-versus-source behavior. |
| Long delay before submission, including unexpected local searches | Include targets such as `&out` and `&template` required SAS runtime resolution. Local preflight tried to find them anyway. An initial fix covered only the compatibility wrapper that the server was not selecting. | Defer unresolved macro-variable include targets to SAS; retain inspection of literal paths and normal SAS error reporting. Fix both wrappers. `tests/test_runner_preflight_parity.pl` and `tests/test_helper_entrypoint_parity.pl` protect the active route and byte identity. |
| Downloads took roughly 58–106 seconds per figure family | Persistent `transfer_many` looped over individual files despite `archive_transfers=true` | Send `bulk_transfer` to the existing session. ZIP batches, batched metadata, integrity checks, staging and cleanup replace repeated transfers. `tests/test_persistent_archive.py` covers flags, corruption, missing members, duplicates and cleanup. |
| Unnecessary custom-macro searches for `%LEFT` and `%TRIM` | Supplied SAS autocall macros were treated as missing user macros | Classify supplied helpers separately, retaining custom-macro discovery. `tests/test_sas_supplied_autocall.pl` protects this distinction. Normal SASAUTOS configuration remains required. |
| Regional and forest requests were still slow after batching | Profiling found repeated scans of the preceding source for every quoted literal in 375–381 KB macro payloads | Calculate executable-string contexts once per analysis, preserving separate CALL EXECUTE, DOSUBL and RESOLVE semantics. Reuse lexical analysis for masking and include discovery. `tests/test_literal_execution_contexts.pl` plus existing quoting, include-order and dependency tests protect behavior. |
| Nested upload/download paths failed with Cygwin Perl and native Windows Python | Only top-level local paths crossed the interpreter path-conversion boundary | Normalize nested bulk payload paths for the selected Python, preserving remote SAS paths and caller input. `tests/test_python_path_boundary.pl` performs real file I/O with spaces. |

The source changes are traceable to these commits, in order:

1. `642118a5715fc8e58eab85d3f8a6d83672303a34` — source filename guards and deferred include inspection.
2. `067c3653fcd21fb5445a3b1167cc2cf04e44a92f` — the same guard in the active server-selected runner.
3. `24741c2996bdd57b5cdf4aa7f383d8cb5a55ca5a` — persistent archive transfers, metadata, path conversion and supplied autocall classification.
4. `fdc6d0f1fcd840d6a87174a5ec6ce36c89e5fa82` — source-analysis optimization.

Both `run_sas_codes_or_files_in_ODA.pl` and
`run_sas_codes_or_script_in_ODA.pl` are now synchronized compatibility entry
points. Check the actual selection in `server.pl`; editing an unused helper
does not fix a server-backed request.

## Measurements and their limits

The same four complete SAS payloads and inputs were used for the accepted
comparison. The programs contain the required original plotting macros on
both routes. Global macro autoload and submission syntax preflight were
disabled on both routes; dependency/include inspection remained enabled in
MCP4SAS. The runs used persistent sessions, starting a fresh named session for
each complete run. These settings describe the experiment, not recommended
shortcuts for production.

| Retained observation | Complete workflow, seconds |
|---|---:|
| Original MCP trial 2 | 816.52 |
| Active include-guard correction, MCP trial 3 | 534.07 |
| Persistent batching correction, MCP trial 7 | 244.64 |
| Source-analysis correction, MCP trial 11 | 149.49 |
| Direct SASPy baseline, trial 2 | 164.27 |

The first-to-final MCP reduction was 81.7% in these observations. Each number
is a single run, collected at a different time. Direct SASPy used individual
transfers; optimized MCP used archives. This is not a controlled estimate of
general speed superiority. The complete times include startup and transfers;
the next table measures submission requests only.

| Figure family | Direct SASPy submit, seconds | Optimized MCP submit, seconds |
|---|---:|---:|
| Clustergram | 9.37 | 13.68 |
| Regional gene/GTF | 6.27 | 21.17 |
| Mutation oncoprint | 2.42 | 5.13 |
| Forest | 4.94 | 18.11 |

For the regional source, the sum of one `macro_dependency_view` and one
`include_targets` call fell from 26.18 to 2.43 seconds. For forest it fell from
23.12 to 2.34 seconds. These are local function measurements, not a complete
accounting of the request: the wrapper invokes analysis at multiple stages.
Do not subtract them from the request and label the remainder as network time.
Process startup, polling, RPC and result handling have not been individually
quantified.

All 72 accepted comparison checks passed: ordered numerical tables agreed at
tolerance 1e-10, and all seven decoded PNG pixel arrays were identical. The
six dependency/include result hashes matched before and after optimization.
Original warnings were retained (clustergram 8, regional 8, oncoprint 2,
forest 0); warnings were not hidden to obtain a pass. The oncoprint uses
invented teaching events. The experiment reproduced plotting and documented
transformations, not a full GWAS or clinical research pipeline.

Model authoring, autonomous debugging trials, tokens, billed cost and human
effort were not measured. MCP4SAS automates dependency handling, transfers,
submission and result collection so an agent can focus on SAS errors. That
workflow benefit should be evaluated separately from raw submission latency.
The sanitized [measurement record](performance/2026-11-12/measurements.json)
preserves timings, source/output hashes, configuration scope and evidence
identifiers. Raw account-specific captures and credentials are not published.

## A repeatable diagnostic sequence

1. **Freeze the workload.** Retain submitted code and input hashes, expected
   outputs, source revision, selected Perl/Python/Java versions, relevant flags,
   session reuse policy and transfer policy. Exclude credentials from shared
   records. If comparing routes, give both the same complete code and inputs.
2. **Check connectivity with a tiny program.** A network policy or login failure
   is not a SAS syntax problem. In this investigation, failed launch and network
   pilots were excluded from accepted timings and retained as failed attempts.
   Do not change scientific code to repair connection problems.
3. **Locate the delay.** Timestamp the caller, wrapper phases, session-server
   request receipt/return, uploads, submit and downloads. `wrapper_submit` only
   means the wrapper is active; it does not establish that SAS started. A long
   gap before the session receives `submit` calls for local profiling first.
4. **Prove which path executed.** Record the active helper and session protocol
   version. Persistent batching requires protocol
   `2026-11-12-persistent-archive` or a compatible later implementation. Verify
   an actual `bulk_transfer` RPC and whether fallback occurred; a configuration
   flag by itself does not prove batching. Restart stale helpers through the
   normal lifecycle when testing a new protocol.
5. **Profile the frozen source offline.** From the repository root:

   ```bash
   perl tools/profile_sas_source.pl --repeat 3 \
     --output source-profile.json /path/to/analysis.sas
   ```

   This measures analysis functions without SAS or network access, checks
   repeated result hashes and reports source hashes. Hashing is outside the
   timed intervals. Run it against the same bytes at each revision. Preserve
   function-result hashes as well as timings: faster dependency discovery is
   useless if it changes which executable includes are discovered.
6. **Make a narrow correction and test the boundary.** Protect inert strings,
   nested calls, escaped quotes, runtime include paths, literal includes,
   custom versus supplied macros, source order, archive failures and native
   versus Cygwin paths. Keep wrapper entry points synchronized. Do not disable
   checks, suppress errors or remove required macro dependencies for speed.
7. **Rerun the real route.** Compare SAS logs and numerical tables independently
   of graphical appearance. Retain unsuccessful attempts. Repeat with
   controlled order and transfer/session settings before estimating general
   latency differences; save per-stage timings rather than only a grand total.

On Windows, invoke Cygwin Perl scripts with repository-relative, forward-slash
or converted Cygwin paths. A backslash-form absolute script path can confuse
FindBin before the intended code is reached. Keep local interpreter paths
distinct from remote SAS paths.

The publication checks also exposed a one-shot status-file boundary failure:
native Windows Python inherited a Cygwin `SAS_ODA_STATUS_FILE`, which raised a
file error and masked the intended Java connection diagnostic. Both one-shot
launch paths now convert that environment value for the selected Python.
`tests/test_java_setup_help.pl` exercises the actual CLI with a failing SASPy
stub and requires the original Java guidance, failure exit and unmasked status
handling. This correction does not change the retained persistent-run timings.

## Regression and installation checks

Follow [VALIDATION_TASKS.md](VALIDATION_TASKS.md) for the complete offline tier.
The installation smoke check also runs the focused input-boundary, wrapper,
autocall, literal-context, path and archive regressions. For this change the
retained live four-family checks complement the offline suite; they do not
establish that every platform or research example was rerun.

```bash
prove tests/test_helper_entrypoint_parity.pl \
  tests/test_poc_input_boundaries.pl tests/test_runner_preflight_parity.pl \
  tests/test_sas_supplied_autocall.pl tests/test_literal_execution_contexts.pl
cmp -s run_sas_codes_or_files_in_ODA.pl run_sas_codes_or_script_in_ODA.pl
# Use the Python selected by your MCP4SAS installation:
PIPELINE_PYTHON_BIN=/path/to/python prove tests/test_python_path_boundary.pl
/path/to/python tests/test_persistent_archive.py
bash install/check_mcp4sas_install.sh
```

Archive staging protects existing downloads from validation failures. Promoting
multiple files is not an atomic transaction across all destinations. Supplied
autocall classification assumes the standard SAS libraries are configured.
Performance on large unrelated programs and other platforms must be measured,
not inferred from this evaluation.

## Saved SAS programs without an AI agent

The Perl runner remains usable from a terminal:

```bash
perl run_sas_codes_or_files_in_ODA.pl --file analysis.sas \
  --persistent --session-id myproject
```

This uses the configured SASPy/Java/ODA backend and MCP4SAS orchestration; it
does not require a model request for each saved-program execution. A retained
CLI smoke test completed in 2.47 seconds using an existing session, with
preflight enabled, a completion marker and zero SAS error lines. This verifies
the route, not a representative analysis runtime. Reusing code without a new
AI request avoids model-token charges for that execution.
