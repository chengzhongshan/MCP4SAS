# Complete runner test review

Execution window: November 14–15, 2026. Work branch:
`test/complete-runner-suite`, starting from `b6157ef`.

The remaining root `tests/` programs were exercised, missing native Python
counterparts were added, reproduced failures were corrected, and the resulting
SAS evidence was independently rechecked. All **80 root Perl test/catalog scripts
now have Python counterparts** beside them. The Python runtime and its published
test counterparts do not launch Perl; explicitly named maintainer orchestrators
can select the original Perl implementation for comparison.

## Actual results

| Check | Result | Evidence |
|---|---|---|
| Final combined offline suite | **116/116 scripts passed**: 54 Perl, 59 Python, 3 Bash | Local `MCP4SAS_Use_Python/test-results/final-all-offline-verified/coverage.json` and individual logs |
| Existing Python package unit suite | **64 tests passed** | Local `MCP4SAS_Use_Python/test-results/final-native-unit-tests.log` |
| Numerical SAS collections, Python | **4,550/4,550 verified** | Submitted SAS, full logs, terminal status and source/oracle hashes retained |
| Numerical SAS collections, Perl | **4,550/4,550 verified** | Same original SAS programs and reviewed oracles, rechecked independently |
| Eight MCP example catalogs, Python | **590/590 verified after explicit reruns** | Initial attempts and the complete reviewed batch-5 rerun retained |
| Eight MCP example catalogs, Perl | **590/590 verified after explicit reruns** | Original attempts plus separate case 26, 129 and 240 reruns retained |
| Cross-language evaluation-contract hashes | **4,550 checked; zero mismatches** | Local `MCP4SAS_Use_Python/test-results/evaluation-module-parity.json` |
| Final Python CI | **6/6 jobs passed**, Windows/macOS/Ubuntu × Python 3.10/3.13 | [Run 43685346908](https://github.com/chengzhongshan/MCP4SAS/actions/runs/43685346908) |
| Targeted Perl CI | **3/3 jobs passed**, Windows/macOS/Ubuntu | [Run 43683422685](https://github.com/chengzhongshan/MCP4SAS/actions/runs/43683422685) |

A verified negative case means that its intended SAS error was observed and
reported correctly. It does not mean the SAS job succeeded. The numerical
collections contain 500 cases in rounds 1–8 and 10, and 50 raw macro-boundary
cases in round 9. The additional 590 MCP examples are a separate collection.
Together these represent **10,280 verified runner/case outcomes across the two
runtimes**, excluding the extra focused smoke tests and repeated attempts.

The [execution manifest](COMPLETE_TEST_EXECUTION_MANIFEST.json) contains the
numerical round totals, individual catalog attempts, rejected original attempts,
and program/log/status/response hashes. Its audit revision identifies the
validator, rather than asserting that every earlier submission used that final
Git revision. Exact SAS bodies and oracle contracts are rechecked. Full execution
artifacts remain under the ignored local `test-results/` and `SAS_Output_*`
directories; the committed manifest contains hashes and relative locations.

## Reproduced defects and corrections

**Single-file uploads with apostrophes failed in Python.** Multiple uploads
already used the safe SAS ZIP-copy path, but a single `author's.sas` bypassed it
and failed in SASPy. Both archive-helper copies now select the safe one-member
ZIP path for those filenames. This applies even when optional multi-file
batching is disabled, and is documented explicitly. Live direct, abbreviated,
list, DOSUBL and CALL EXECUTE includes passed after the correction.

**Deferred path rewriting did not preserve nested SAS quoting.** Local paths can
contain doubled or quadrupled apostrophes inside deferred includes. Rewriting
now handles those escaped spellings and applies replacements against original
source spans once. It does not recursively rewrite a newly inserted remote path.

**Python preflight did not match the structural safeguards of the Perl CLI.**
Lexical and structural macro-control failures, including failures in discovered
local include files, now produce a complete failed status and retained report
before opening SAS. Format and fileref naming hints remain advisory. Raw
compiler tests explicitly disable submission preflight; ordinary runs retain it.

**Raised SASPy termination exceptions lost their infrastructure classification.**
They previously became generic exit 1, allowing later catalog submissions to
continue using the same dead bridge. The CLI now preserves exit 74 and
`sas_oda_remote_session_termination`, discards only that owned bridge, and never
replays the interrupted SAS submission. A later explicit submission can obtain
a fresh session. Source listings and macro traces cannot fabricate termination
through an echoed string.

An actual isolated `ENDSAS` test verified exit 74, an explicit subsequent fresh
session with no surviving old WORK table, and closure of that test session.
Discarding a definitively unusable bridge no longer waits the normal timeout
grace period. The focused termination step measured **22.114 seconds before** and
**7.615 seconds after** that change; recovery then took 6.821 seconds. These are
individual diagnostic observations, not a controlled general performance
benchmark. Grace handling for uncertain timeouts remains configured separately.

**The older MCP catalog evaluator could accept an infrastructure failure.** Its
diagnostic search covered the whole report, including the input filename. The
original Perl abort attempt returned exit 74 with an empty SAS log, yet the
filename `26_abort_cancel.sas` satisfied its `abort|cancel` search. Both evaluators
now require an actual SAS runtime diagnostic, reject infrastructure/worker exits
as proof of an intentional SAS error, and look for computed markers in the SAS
log. A new regression checks filenames, source echoes and infrastructure exits.
The explicit Perl case-26 rerun produced the real ABORT CANCEL error with exit 1
and passed the stricter guard.

**Late catalog-reference failures left partial generated outputs.** Python now
validates every source reference before creating the output directory. A final
case with an invalid reference cannot leave earlier generated files behind, and
an existing valid output directory is preserved.

**Windows Git-sync testing selected the WSL launcher.** The test and suite now
prefer Git Bash when appropriate, or honor an explicitly supplied Bash. The
isolated bare-repository tests then passed, including conflict handling and
protection of credential/output files.

## Expectations corrected without hiding SAS diagnostics

Case 240, `dictionary_columns_work_lookup`, declares a character column without
assigning it a value. Its numerical result is correct, and SAS emits
`NOTE: Variable word is uninitialized.` The catalog incorrectly demanded no
data-quality note. The expectation now records that note explicitly; the SAS
program was preserved. The native frozen catalog was regenerated from the
reviewed Perl source and pinned to that source version.

**All 590 original SAS example bodies were preserved.** No SAS warning was
suppressed to make this test run pass. The case-240 change concerns its expected
diagnostic contract. Both runtimes executed it again with that contract. The
auditor rejects old expectations rather than silently promoting stale evidence.

## Original failures remain visible

The independent catalog audit retains **40 rejected original Python attempts**:
the case-240 expectation mismatch, one unexpected session termination at case
252, and 38 subsequent submissions affected by the dead-session classification
bug. The complete batch-5 rerun passed all 100 cases after correction.

It also retains **three rejected original Perl attempts**: the case-26 false
positive, a session interruption at case 129, and the case-240 expectation
mismatch. Each has a separate passing, explicit rerun. The original full-catalog
orchestrator exits remain nonzero where those original failures occurred; the
final independent audit establishes complete current-contract coverage from all
retained attempts. Failed logs were not overwritten.

The underlying SAS service cause of the unexpected disconnections was not
established. The corrected reporting, no-replay behavior and recovery were
verified. A successful rerun is not evidence that the service can never
disconnect again.

## Python coverage and reproducibility

The [counterpart map](TEST_COUNTERPART_MAP.csv) records all 80 Perl/Python pairs
with source hashes and coverage type. Seventeen source-analysis counterparts
replay 254 distinct captured API vectors through native Python. These are
differential compatibility checks. Other counterparts use native functional
tests, the original numerical SAS manifests, or focused native unit tests.

The [script execution inventory](TEST_SCRIPT_EXECUTION.csv) classifies all 172
executable files now in the root test directory, including the maintainer
orchestrators and catalogs. Catalog loading/generation is distinguished from
offline assertions and actual SAS execution.

Perl-specific implementation internals are not recreated unnecessarily. For
example, Python's prevalidation counterpart checks native catalog generation;
the separate Perl book-corpus generator remains in the original implementation.
The full port inventory now lists 105 implemented entries out of 116 inventoried
Perl sources; remaining developer-only generators/modules are still identified
as deferred. This is not a claim that every Perl source in the repository has
been translated.

The expanded Python CI runs every offline native root counterpart and uploads
per-script coverage/log artifacts. The targeted Perl CI covers its established
runner checks; it is not the full 54-script local Perl suite. See
[tests/README.md](../tests/README.md) for exact rerun commands, raw-test opt-in,
output locations and independent evidence auditing.

## Scope and limits

- Actual SAS OnDemand execution used this Windows workstation, native Python
  and Cygwin Perl. macOS/Ubuntu CI verified offline/runtime/protocol behavior;
  it did not establish live ODA connectivity or licensed local SAS on those hosts.
- Fake local-SAS and COM ownership tests check programming contracts. They do
  not replace a live licensed local-SAS test on every platform.
- No AI writing/debugging trials or token/cost benchmarks were run. Script
  elapsed times under concurrent tests are not a direct-vs-MCP performance study.
- This work validates runner regressions and retained teaching examples. It is
  not full scientific or publication validation of the book or every research
  workflow. The original book and research repositories were not revised.
- The pre-existing four-blank-line change in
  `MCPDeps/sas_oda_session_server.py` and untracked `debug.log` remain outside the
  commits. The VS Code extension version remains 0.1.5.
