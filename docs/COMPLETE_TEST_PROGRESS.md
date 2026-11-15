# Complete runner regression work

Requested scope: execute all remaining root `tests/` scripts; add native Python
counterparts based on the Perl tests; fix reproduced defects and improve repeatable
execution. Work branch: `test/complete-runner-suite`, based on `b6157ef`.

## In progress (checkpoint after native corpus execution)

- Offline original suite passed after selecting a functioning Bash. New native
  counterparts have been added beside every root Perl test/script. Final combined
  suite and CI runs are pending; earlier failed runs remain available.
- Original live tests and nine numerical corpus rounds are running sequentially
  through `tests/run_remaining_live.py`, using isolated backend and HTTP ports.
- All 4,550 original numerical cases passed through the Python CLI, including
  50 raw macro-boundary cases. Independent saved-evidence audits reverified all
  4,550 source/oracle contracts. Original Perl corpus runs are still in progress.
- All eight original example catalogs (590 cases) have started through each
  runtime's MCP pipeline. Do not infer their completion from numerical-corpus
  results.
- Added native evaluation-contract, source-integrity and runtime-log evaluation
  functions. Captured hash-pinned public source-analysis calls from 17 original
  Perl tests for differential replay by Python without invoking Perl.
- Fixed single-file apostrophe uploads, nested quoted dependency rewriting,
  structural preflight terminal status, and late catalog prevalidation failures.
  Live quoted-include reruns and the existing 64 Python unit tests passed.
- Author's pre-existing four blank lines in `MCPDeps/sas_oda_session_server.py` and
  untracked `debug.log` are outside this work.

## Evidence locations (ignored local execution outputs)

- `MCP4SAS_Use_Python/test-results/complete-suite/coverage.json`
- `MCP4SAS_Use_Python/test-results/remaining-live/execution.json`
- `MCP4SAS_Use_Python/test-results/python-counterparts-initial/coverage.json`
- `MCP4SAS_Use_Python/test-results/remaining-parity/`

These files are execution records, not publication or scientific validation. Live
tests have not all finished; a generated test or passing preflight is not evidence
that its SAS program ran successfully. This progress file must be updated as work
continues, including remaining failures and unexecuted branches.
