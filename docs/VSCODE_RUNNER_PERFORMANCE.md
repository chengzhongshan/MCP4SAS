# VS Code MCP calls and direct runner performance

The extension does not make SAS computation faster than the same runner in a
terminal. It provides tool discovery, selected-target routing, dependency
handling and structured results to Copilot or Codex. For a saved SAS program,
the Python or Perl CLI is a useful alternative that needs no MCP server or AI
request. Both routes retain the applicable runner checks.

## What caused the visible delay

The VS Code relay starts an owned, loopback-only Perl server and reuses it for
the selected target. It does **not** start a new HTTP server for every tool
call. The Perl server invokes the same Perl runner used at the command line.
The Python MCP server similarly invokes the native Python runtime.

Previously, every submission returned a PID immediately. The instructions then
told the assistant to wait about 30 seconds before polling. A program that
finished in 13–18 seconds could therefore take 30 seconds to report completion.
This was result-observation latency, rather than extra SAS computation.

The SASPy MCP tools now wait up to **20 seconds** for a durable completion
record and return the verified result immediately when it is available. A
longer job returns `RUNNING`, its PID and `poll_after_seconds: 5`. Known long
analyses can still be polled less frequently. This wait does not shorten the
SAS execution timeout, rerun the program, bypass preflight, or change session
reuse. The separate direct-local-batch tools retain their background behavior.
The Perl HTTP handler is occupied during that bounded wait; concurrent clients
that need immediate dispatch can set zero and manage polling themselves.

```json
{"sas_codes_or_file":"proc print data=sashelp.class;run;","wait_seconds":20}
```

Use `wait_seconds: 0` when an application specifically needs the old immediate
background response. Values from 0 to 30 are accepted on submission and poll.
Clients must inspect `structuredContent.status` **on the first response**:
`COMPLETE` and `FAILED` are terminal; only `RUNNING` needs another status call.
Older clients that always expect a new PID should explicitly request zero.

Long returned logs are excerpted by default at 16,000 log characters; the
complete log remains on disk. Diagnostics are calculated from the full log
before excerpting. `log_truncated` and `log_path` identify that situation.
`max_log_chars: 0` explicitly requests the full log. Diagnostic summaries and
metadata are additional to the excerpt limit. This can reduce response size;
actual model-token charges were not measured.

## Live measurements: 15 November 2026

The same SASHELP.CLASS program printed five observations and independently
checked that the table contained 19 rows. Each route started a fresh SAS
session; browser opening and global macro autoload were disabled equally.
Normal submission checks remained enabled. No files required upload. The two
optimized rounds used different route orders. Full code, hashes and sanitized
observations are in [the measurement record](validation/plugin-latency-20261115.json).

| Target | Previous MCP delivery, one run | Optimized MCP, two runs | Direct Perl, two runs | Direct Python, two runs |
|---|---:|---:|---:|---:|
| Windows SAS / COM | 30.128 s | 16.822–17.620 s | 17.314–17.591 s | 14.451–14.595 s |
| SAS ODA / IOM | 30.129 s | 13.254–13.412 s | 13.209–13.262 s | 11.016–11.314 s |

MCP times start after initialization and end with verified completion. Initial
relay/server discovery took another **1.93–2.11 seconds** in these runs and is
reused while that relay and target remain active. Direct CLI times include
runner process startup. Initialization and SAS execution are distinct costs;
neither table column is a SAS-only timing.

The previous MCP measurements actually used a 30-second polling interval; they
are not modeled estimates. Short optimized jobs needed one tool call instead
of two. The optimized MCP route was close to the **same Perl runner**, while
the native Python CLI remained about 2–3 seconds faster. These small samples
do not establish a general ranking for network, macro-heavy, persistent-session
or large-transfer workloads. This was a controlled programmatic relay probe,
not a timed human Copilot/Codex conversation. No model tokens or billed costs
were measured, and there were no live macOS/Linux SAS executions.

Three live negative ODA runs also verified the same missing-dataset SAS error
through Python, MCP and Perl. Windows asynchronous checks exercised explicit
short waiting and reuse of one relay across successive jobs. Offline transport
tests verify that a lost reply never triggers automatic resubmission.

Two discarded direct-Perl pilot attempts passed a Cygwin-form SASPy configuration
path to native Windows Python. The corrected tests supplied the native path,
as the plugin does. Those failures and a development-copy missing-Mojolicious
pilot are recorded separately; they are not successful performance samples.

## When a direct-runner fallback is safe

A slow or lost MCP reply is **not** proof that submission failed. The backend
may already be running SAS or changing files. Automatically invoking a second
runner on timeout can duplicate an analysis, upload, update or deletion.

The relay now reports recovery metadata on JSON-RPC errors:

- Before forwarding a SAS tool request: `request_forwarded: false` and
  `safe_to_retry_via_runner: true`. Check the intended target, then a direct
  runner is a reasonable fallback.
- After forwarding: `request_forwarded: true` and
  `safe_to_retry_via_runner: false`. Inspect the existing PID, retained log,
  status file and completion record. Resolve that job before submitting again.

These are conservative dispatch facts, not an automatic failover service or
an exactly-once execution guarantee. A target-mismatch rejection must be
resolved before retrying; a direct command must not bypass the selected-target
decision. Initial setup errors now return a JSON-RPC error instead of ending
the relay without a recoverable response. There is no blind timeout replay.

Once it is safe to submit, from the installed project folder:

```bash
python run_sas_codes_or_files_in_ODA.py --file analysis.sas --saspy-cfgname oda
# Equivalent Perl entry point:
perl run_sas_codes_or_files_in_ODA.pl --file analysis.sas --saspy-cfgname oda
```

Use the same configured SASPy profile/configuration as the intended VS Code
target. Windows COM is one-shot; do not add persistent flags there. Compatible
ODA/IOM profiles can use `--persistent --session-id myproject` to reuse SAS
state across planned submissions. A direct CLI invocation does not change the
plugin target. Its browser behavior is independent of background MCP jobs.

For a temporary MCP outage, read the full log at the returned `log_path`. The
job result directory contains `worker.result.json` when the worker finishes,
until the Perl poll consumes that completion marker. The SAS log and HTML
remain. Do not kill all SAS sessions simply to investigate a slow response.

## Repeat this comparison

The opt-in harness uses an existing runtime configuration without editing it.
Keep its output private: copied runtime metadata and logs can contain personal
paths. It calls actual SAS and never calls an AI model.

```bash
python tests/benchmark_plugin_routes.py --live \
  --runtime-config /path/to/runtime.json --node /path/to/node \
  --out SAS_Output_route_benchmark --repeat 2
```

Run separately for each configured target. `--case sas_error` checks a real
missing-dataset failure; `--routes mcp --wait-seconds 0.05` exercises background
delivery. It submits no research findings and makes no token/cost estimates.
Keep dependencies installed in the selected source checkout; a Git source
copy by itself is not a configured runtime.

After updating the source and VSIX, reload VS Code once so its existing MCP
process uses the new code. Extension version remains **0.1.5**.
