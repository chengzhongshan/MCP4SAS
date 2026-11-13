# Showcase package verification

Checked on 13 November 2026. The author-supplied Word documents and the five
scientific SAS payloads were preserved unchanged. This record describes
packaging checks and two new saved-program executions, not a new performance
comparison or autonomous-agent trial.

## New executions through the public example helper

The exact public `examples/poc/run_example.pl` helper ran against the configured
SAS OnDemand for Academics account using Cygwin Perl and native Windows
Python/SASPy. Syntax/dependency preflight remained enabled. Required definitions
are already present in the frozen programs, so global macro autoload was off.
Both cases reused one isolated named session. The test's own session server was
shut down afterward; other session servers were not affected.

| Case | Returned files | Output checks | SAS ERROR lines | SAS WARNING lines |
| --- | --- | --- | --- | --- |
| `hello` | 19-row `hello.csv`, PRINT HTML and complete log | 3 passed | 0 | 0 |
| `oncoprint` | 2 PNGs, 2 SVGs, 6 numerical CSVs and complete log | 33 passed | 0 | 2 |

The oncoprint warnings were `No output destinations active` and the warning
about a very large `(3420, 2430)` output size and possible Java VM memory
exhaustion. Outputs were generated and collected, but these warnings remain
relevant when choosing output dimensions or reusing the program. The example
was not changed to suppress them. Read the complete log on each new run.

The helper verified the completion marker and actual WORK directory in the log,
downloaded the manifest's output files from that same session, and invoked the
independent numerical checker. Logs and full execution records remain in the
author's local evaluation archive; private account configuration is excluded
from Git. The public [execution record](verification.json) contains source,
log and output hashes without account paths or credentials.

## Checks against retained scientific outputs

The new Perl checker was also run against the existing optimized PoC outputs:

| Case | Passed file, row-count and selected numerical checks |
| --- | --- |
| `clustergram` | 509 |
| `gene_gtf` | 59 |
| `oncoprint` | 33 |
| `forest` | 30 |
| `multi_gwas_gtf` | 11,295 |
| **Total** | **11,926** |

These checks reuse retained results; they are not fresh executions of the
other four scientific cases. Assertions independently cover within-gene
expression standardization, regional bounds, assessable mutation denominators,
approximate log-OR/SE reconstruction and signed LD arithmetic. Successful
arithmetic does not establish biological validity.

## Offline package checks

Run `perl tests/test_poc_showcase.pl` without SAS credentials. It checks source
hashes, six extracted PNG signatures, local documentation links, balanced code
fences, all six CLI dry-run plans, invalid case/session handling and rejection
of an incomplete returned table. All 201 local assertions passed. GitHub Actions runs the same package test on
Linux, macOS and Windows. Actual CI results are reported with the publishing
commit rather than inferred from this configuration.

All six embedded figures were visually inspected. They are the original
document images, not redrawn or substituted figures. The forest preview has
tight left-edge label spacing in the supplied original; it is retained rather
than silently edited. The Word files were not re-typeset. This task does not
claim new Word-pagination inspection or publication readiness.

## Scope of evidence

The original comparison's 72 checks and the multi-GWAS comparison's 19 checks
remain separate from the new checker counts above. Original runtime values
are retained in the edited PoC. New runs here were smoke tests of the published
helper, not timed paired comparisons. No new claims about model tokens, billed
cost, authoring speed, debugging efficiency or human effort follow from them.
