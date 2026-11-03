# Open-code macro evaluation: M4001–M4050

These are **50 distinct boundary examples**, not ten parameter variations of five
templates. Their normalized executable bodies differ from all 4,000 earlier
programs. They use synthetic data and actual source/line evidence from the macro
books in the requested SAS book sample directory. Original book files are unchanged.

Forty-nine source anchors come from *Carpenter's Complete Guide to the SAS Macro
Language, Second Edition* and one from *SAS Macro Programming Made Easy, Second
Edition*. Three `derived_extension` entries explicitly anchor modern boundary
experiments to a real macro definition instead of claiming that the exact newer
statement occurs in the older book. The manifest records titles, filenames,
lines, source/line hashes, executable hashes, numerical/error/warning oracles
and evaluation-contract hashes in the run evidence.

| IDs | Examples |
| --- | --- |
| M4001–M4003 | Supported open-code IF/DO, ELSE and sequential conditionals |
| M4004–M4006 | Indexed, WHILE and UNTIL loops correctly wrapped in macros |
| M4007–M4011 | LOCAL scope, RETURN, GOTO, inert definitions and nested IF inside macros |
| M4012–M4018 | STR/NRSTR, quoted controls, comments and DATALINES4 records |
| M4019–M4025 | Option restoration, EVAL/SYSEVALF, SUPERQ, delimiters, indirect references and SYMPUTX timing |
| M4026–M4030 | Invalid open LOCAL and indexed/WHILE/UNTIL/standalone DO |
| M4031–M4033 | Orphan END, ELSE and THEN |
| M4034–M4036 | Nested open IF, missing DO action and missing-semicolon recursion |
| M4037–M4039 | Invalid open GOTO/RETURN and orphan MEND |
| M4040–M4045 | EVAL division/decimal errors, unknown SYSFUNC, duplicate parameters, argument ordering and empty IF |
| M4046–M4050 | Unresolved variables/invocations, missing symbol deletions and recursive defaults |

The final outcomes are **29 successful MCP jobs, 20 intended SAS-error jobs and
one intended MCP policy failure**. Five cases have required actual warnings.
M4047 is special: SAS produces a warning and the expected numeric marker, while
MCP4SAS deliberately fails unresolved macro invocations. This existing protective
policy is retained and verified separately from SAS ERROR severity.

The shared source analyzer now catches 14 structural problems before submission,
compared with three in the preserved baseline. Thirty positive/warning examples
remain unblocked. Six expression/parameter errors still require actual SAS
evaluation; the static scanner is not a complete macro interpreter. Supported
open-code conditional groups assume SAS 9.4M5 or later.

MCP job summaries now include categorized macro diagnostics and hints. Source
echoes and submitted strings cannot fabricate these diagnostics. Warning-only
oracles require actual WARNING lines plus a runtime marker and correct status;
the strict unresolved-invocation case additionally requires the failed wrapper
exit. Timeout messages invalidate expected-error checks even when the wrapper
uses exit 1.

From the MCP4SAS checkout in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_macro_open_code50.pl \
  '/cygdrive/h/F_Queens/360yunpan/SASCodesLibrary/SAS PDF/sas online samples'
prove tests/test_macro_open_code50.pl tests/test_open_code_macro_diagnostics.pl
perl tests/run_live_macro_open_code50.pl --live --raw
perl tests/test_live_open_code_preflight.pl --live
```

`--raw` is required for the diagnostic runner: it deliberately bypasses static
preflight to compare actual SAS behavior. Ordinary helper commands retain the
preflight checks. Each diagnostic case uses a fresh one-shot SAS connection,
with a 120-second timeout; invalid macro parser state cannot leak into another
case or a user's persistent session. The normal-helper live probe checks both
helper aliases and proves that five structural problem types are blocked before
remote submission (30 checks).

On **2026-11-02**, independent collection verified **50/50 distinct outcomes**
across four runs. The initial run reported 46/50. Focused reruns addressed one
DATALINES fixture, one bounded IF fixture/diagnostic, the exact duplicate-parameter
message and explicit classification of the existing unresolved-invocation policy.
This was not a clean 50/50 single invocation.

```bash
perl tools/collect_library_evaluation_results.pl --round 9 --skip-stale \
  --run SAS_Output_library500_live_929bKH \
  --run SAS_Output_library500_live_SLzFMj \
  --run SAS_Output_library500_live_lENbeZ \
  --run SAS_Output_library500_live_URkMwa \
  --output tests/macro_open_code50/verified_results_2026-11-02.json
```

`--skip-stale` explicitly excludes entire batches whose source or evaluation
contract changed. The audit retains them in `stale_attempts` with original exits,
terminal messages and hashes. They never count as passes. Without this option,
such mismatches still fail collection. Submitted source, current hashes,
contracts, actual logs, exits and terminal JSON are rechecked for every accepted
case. The four excluded initial attempts and original timeout remain visible.

Programs, logs and statuses remain in ignored run directories. See section 25
of `../../RealExamples4ImprovingMCP4SAS.md` for the detailed failures, fixes and
final regression counts. No Python evaluation scripts were introduced.

The complete final offline suite passed **5,307 top-level checks across 44
files**. A read-only audit matched all 50 provenance records to their original
book files; default helper cleanup left no `.mcp4sas_work_*` directories.
