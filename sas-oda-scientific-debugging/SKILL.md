---
name: sas-oda-scientific-debugging
description: Debug SAS OnDemand scientific workflows through MCP4SAS using reproducible probes, bootstrap evidence, preserved logs, and minimal live reruns.
---

# SAS ODA Scientific Debugging

Use this skill when a SAS ODA scientific workflow hangs, cannot resolve a macro,
returns contradictory bootstrap diagnostics, or produces output that needs both
software and scientific validation.

## Evidence Order

1. Preserve the generated SAS log, bootstrap-only log, status JSON, and rendered
   SAS source before changing code.
2. Reproduce with the smallest named persistent session and a bounded timeout.
3. Separate connection, macro bootstrap, macro availability, execution, output
   transfer, and scientific-result checks. Success at one layer proves nothing
   about the next layer.
4. Probe the exact required capability, such as
   `%sysmacexist(Del_Dir_Recursive)`, rather than an unrelated familiar macro.
5. Rerun the original scientific call after the narrow probe passes.

## Macro Bootstrap Rule

Never use the existence of one macro as proof that a complete macro library was
loaded. SAS ODA can precompile `DEBUG_MACRO` in `WORK.SASMAC1` while user macros
in `~/Macros` remain absent. Therefore `_pipeline_debug_macro_exists=1` is a
diagnostic observation only, not a valid bootstrap sentinel.

For a new SAS ODA session:

- run `importallmacros_ue` against the complete `~/Macros` directory;
- cache the session as loaded only when that bootstrap reports success;
- verify the macro requested by the submission after the full import;
- conditionally include its source from `~` or `~/Macros` only if the requested
  macro is still missing; and
- keep that targeted include supplemental. It must not replace the complete
  library import when the workflow depends on interconnected macros.

Do not report a targeted include as failed from inside the same wrapper macro
that issued `%include`. Macro compilation can become visible only after that
wrapper returns. Place the `%sysmacexist` verification after the loader wrapper
call, or perform it in a later SAS submit.

Distinguish two targeted-loading policies in persistent sessions:

- after the complete `~/Macros` bootstrap, a supplemental fallback may include
  a requested source only when the macro is still missing; but
- when global autoload is disabled and a targeted lookup resolves an explicit
  source, include that source even if `%sysmacexist` is already true. Otherwise
  a compiled fallback-folder macro can mask a newer or higher-priority source.

## Required Regression Checks

Before accepting a bootstrap fix, verify all of the following:

```text
Bootstrap OK: 1
Bootstrap Skipped: 0
Bootstrap Warning: 0
<REQUESTED_MACRO_CHECK>=1
```

Also search both the bootstrap and job logs for `ERROR`, `WARNING`, unresolved
macro invocations, and timeout messages. A generated HTML file or an exit code
of zero is not sufficient evidence by itself.

Use a nonexistent scratch directory when testing destructive cleanup macros.
Never point a diagnostic deletion call at real scientific inputs or results.

Keep test harness failures deterministic. In Perl fixtures that intentionally
use `die` and assert exit `255`, set `$! = 0` immediately before `die`; stale
errno from an earlier filesystem call can otherwise become the process exit
code. Prefer asserting the behavioral contract over incidental runtime state.

For a slow live request, inspect the status phase before calling it a hang.
`upload_progress`, `submit_active`, and `submit_returned` identify different
boundaries. Let the configured timeout own termination, then verify descendant
process cleanup and the final status JSON.

Treat `%include` discovery as a lexical execution question. A direct
`%include` inside a double-quoted DATA-step string is text, even though ordinary
macro references can resolve inside double quotes. Do not upload or wrap that
path. Continue to recurse into single-quoted code only when it is an argument
to an execution API such as `DOSUBL` or `CALL EXECUTE`.

Classify unquoted PRX literals before diagnosing block-comment boundaries.
Macro-language calls such as `prxmatch(/\s*&linker\s*/,&value)` legitimately
contain `*/` where a greedy quantifier meets the closing regex delimiter. That
pair is not an unexpected comment close. Preserve warnings for a real stray
`*/` and for malformed nested constructs such as `/* /* text */ */`; use
source-provenanced PRX cases to keep those behaviors separate.

An ownership marker authorizes deletion only when its canonical root matches,
its directory has the owned basename, and both timestamp and PID are numeric.
Require PID to be positive: PID zero has process-group semantics on Unix and
must never be accepted as an owned-process identity.

Treat `run_sas_codes_or_files_in_ODA.pl` and
`run_sas_codes_or_script_in_ODA.pl` as synchronized compatibility entry
points. A one-sided edit passes Perl syntax checks but fails every platform's
installation smoke test. After changing either helper, run the parity test and
the installer check before pushing:

```bash
prove tests/test_helper_entrypoint_parity.pl
cmp -s run_sas_codes_or_files_in_ODA.pl \
  run_sas_codes_or_script_in_ODA.pl
bash install/check_mcp4sas_install.sh
```

## Scientific Validation

Once execution is clean, validate the scientific contract independently:
expected sample and variant counts, genomic bounds, group labels, missing-value
handling, output tables, and plot contents. Preserve the exact inputs and
configuration used for the successful rerun so the result is reproducible.
