# SAS ODA examples and failure checks

For additional generated examples that exercise the MCP HTTP transport,
persistent sessions, and archive transfers, see [MCP HTTP examples](mcp_http_examples.md).

These examples run through the same CLI runner used by the MCP server.
The live checks use your configured SAS ODA credentials. The GTEx example
also requires outbound HTTPS from SAS ODA to the public GTEx API.

```bash
SAS_ODA_AUTOLOAD_MACROS=0 OPEN_RESULT=0 \
  perl run_sas_codes_or_files_in_ODA.pl --file examples/gtex_eqtl.sas \
  --output-prefix SAS_Output_gtex --run-timeout-seconds 180

perl tests/run_live_examples.pl --live
perl MCPDeps/test_sas_log_and_labels.pl
```

Global macro autoload is disabled for these self-contained examples. This is
not a recommendation to disable it for programs that use your remote macros.
The live runner retains logs, status JSON, and HTML under a unique
`SAS_Output_examples_*` directory, which is excluded from Git.

| Example | Expected result | Live validation on 2026-10-12 |
| --- | --- | --- |
| `basic_summary.sas` | Summary of `sashelp.class` | Exit 0, successful status, nonempty HTML |
| `macro_control_flow.sas` | Macro labels and literal error text execute normally | Exit 0, no external macro loader |
| `expected_missing_table.sas` | Intentional missing-table error | Exit 1, `success=0`, actual SAS error preserved |
| `gtex_eqtl.sas` | Significant APOBEC3A eQTLs in GTEx v8 | 201 records across 14 tissues |

The live suite passed all 21 assertions. The log/label regression test passed
30 assertions covering both CLI entry points and dependency resolution.
These checks validate the shared runner; they do not exercise the MCP HTTP
transport, local SAS installations, or every SASPy session configuration.

## Failures reproduced and repaired

The macro example originally exited 1 even though SAS produced valid output.
The wrapper interpreted an `MPRINT` source trace containing the string
`"ERROR:"` as an actual runtime error. Fatal error matching now requires a
diagnostic at the beginning of the log line (allowing leading whitespace).
Numbered source listings remain excluded. Actual `ERROR:`, numbered SAS
errors, and unresolved-macro warnings still cause failure.

The same example also triggered an unnecessary remote loader for
`finished.sas`: the dependency scanner mistook `%finished:` for a macro call.
Label declarations are now excluded while real external macro calls still
receive dependency handling.

The GTEx example explicitly pairs the gene version with the dataset:
`ENSG00000128383.12` with `gtex_v8`. It checks HTTP status, paging metadata,
empty responses, and missing data tables before reading results. An HTTP 200
response alone does not establish that the intended data were returned.
This small example rejects results requiring more than one 100,000-record
page rather than silently presenting a partial result. The wrapper cannot
infer whether an empty result is scientifically valid; programs should state
their own expectations as this example does.
