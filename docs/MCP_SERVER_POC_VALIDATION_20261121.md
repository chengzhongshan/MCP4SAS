# Four PoC families through the actual Perl and Python MCP servers

On 21 November 2026, all four selected PoC cases completed through both actual MCP servers: Perl HTTP JSON-RPC and Python SDK stdio. Each route passed **631 file, row-count and numerical checks**. These are live SAS ODA executions, not mocked server responses.

Runtime source commit: `3a87873bb3852b85d849b769c40c15856d27183b`. [Machine-readable evidence](validation/mcp-poc-20261121.json) records frozen input/program hashes, returned output hashes and comparisons. The portable [test harness](../tests/run_mcp_poc_suite.py) remains opt-in; [usage](../tests/README.md#four-scientific-poc-cases-through-both-actual-mcp-servers).

| Case | Checks per server | Perl HTTP seconds | Python stdio seconds | SAS warnings (Perl / Python) |
| --- | ---: | ---: | ---: | ---: |
| clustergram | 509 | 53.939 | 41.964 | 8 / 8 |
| gene_gtf | 59 | 71.389 | 48.488 | 8 / 8 |
| oncoprint | 33 | 35.560 | 28.803 | 2 / 2 |
| forest | 30 | 45.295 | 24.511 | 0 / 0 |

Each server returned all **41 declared output files**, including 25 CSV tables and 7 PNG figures. All 25 CSV tables agreed between servers (text/order and numerical tolerance 1e-10); all 7 decoded PNG images were pixel-identical. Both servers also agreed with the independently run direct Python runner for those tables and PNGs. SVG files were collected and hashed; differing generated identifiers are not treated as changes in scientific values.

Saved local evidence: `SAS_Output_poc_both_20261121/mcp_live/`. It contains each submitted program, full SAS log, MCP request outcome/polls, downloaded outputs, execution records and `gallery.html` for side-by-side inspection. Only test-owned SAS sessions and server resources were closed. The selected VS Code target and private credentials were preserved.

The Perl cleanup submitted `endsas;` to its selected session. That intentional session termination returned exit 74 and a connection-termination diagnostic; it is retained separately from the eight successful plotting executions. The Python selected-session close completed normally.

The original SAS warnings remain: oversized graphics, recursively referenced CREATE TABLE targets and other warnings recorded per case in the manifest. Crowded branch-review labels are not solved by a passing numerical test. The oncoprint is synthetic teaching data. These results validate execution and output consistency for prepared examples; they do not establish biological correctness or publication readiness.

Elapsed times include submission, waits/polling, rendering, transfers and numerical checks. This is one sequential run per route, with Perl first. It is not a randomized performance experiment, and no AI agent, token usage or cost savings was measured. The separate six-case direct-runner evaluation, including the Perl preflight optimization, is documented [here](POC_BOTH_RUNNERS_20261121.md).
