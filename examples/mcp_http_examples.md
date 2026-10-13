# Real MCP HTTP examples

The HTTP test suite generates isolated examples with unique session names and
remote filenames. It checks the complete MCP submission and polling path,
not just the CLI runner.

Start a test server from the repository root using your configured SAS ODA account:

```bash
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl server.pl daemon -m production -l http://127.0.0.1:18089
```

In another terminal, run:

```bash
perl tests/run_live_mcp_examples.pl --live --url http://127.0.0.1:18089/mcp
```

The Perl test uses Mojolicious, already required by MCP4SAS. It polls every 30 seconds and saves
MCP responses under `SAS_Output_http_*`. Full SAS logs and HTML are retained
under `SAS_Output_MCP4SAS_*`. Worker scratch uses `tmp*` and is removed when
the job finishes; polling also removes the temporary completion markers.
These generated directory patterns are excluded from Git.

| Scenario | What is checked |
| --- | --- |
| Missing SAS table with a custom log path | Failed status, nonzero exit, MCP `isError`, and full SAS log at the requested path |
| Persistent session creation | A generated WORK table is created successfully |
| Persistent session reuse | A second call renders the stored value and deletes the test table |
| Archive round trip | Two generated CSV files, including a filename with a space, upload and download byte-for-byte |
| Remote fixture cleanup | Only this test's unique remote filenames are deleted |
| Missing remote download | A file-operation failure is reported through MCP even without a SAS submission status file |

The named persistent session remains reusable after the test; its test table
is removed. The suite does not shut down shared SASPy services or other sessions.

## Failure discovered in live testing

Before the fix, a missing-table job returned `STATUS: COMPLETE` with no MCP
error flag. Its reported log path was also wrong: the server treated the CLI's
`--output-prefix` directory argument as a filename prefix, and polling fell back
to wrapper stdout rather than the full SAS log.

The server records the worker exit status in `worker.result.json`, written
atomically. Polling returns `FAILED` and `isError: true` on nonzero exit,
`COMPLETE` and `isError: false` on exit 0, and `UNKNOWN` with an error flag if a
worker stops without a completion record. Custom log paths are populated after
completion; the canonical job log and status artifacts stay in the job directory.
This also covers transfer-only errors, which may not create SAS submission
status JSON.

Offline reporting regressions can be run without SAS credentials:

```bash
perl tests/test_mcp_job_reporting.pl
```
