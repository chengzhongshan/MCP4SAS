# VS Code integration 0.1.0 validation

Date: 19 October 2026. Server/runner baseline: `af05aed11a74a2146823023f3bf4b6132aaa4a1c`. The original SAS execution engine, macro definitions and existing installers were not edited.

| Check | Actual result |
|---|---|
| Node configuration tests | **10 passed, 0 failed**: real installer paths, Windows/spaced/Unicode paths, TOML validity, unrelated content preservation, idempotence, collisions, malformed blocks, backups, invalid installations and quoting |
| Real VS Code 1.142.0 extension host | **Passed**: isolated profile, extension activation, four registered commands, MCP provider registration, no runtime advertised before setup, and execution using VS Code's bundled Electron/Node |
| Real stdio launcher and original HTTP backend | **Passed**: initialize, initialized notification without unsolicited stdout response, tools/list and clean EOF |
| Actual SAS ODA positive submission | **COMPLETE**, exit 0: `SASHELP.CLASS` Age known=19, absent=0, youngest=11, oldest=16 |
| Actual SAS ODA negative submission | **FAILED**, exit 1: deliberately absent `WORK.EDITOR_INTENTIONALLY_ABSENT`; the failure is the expected result |
| Native Codex app-server calls through the new launcher | **Passed**: actual positive and negative SAS calls using temporary configuration overrides; personal Codex configuration was not changed |
| Backend cleanup | The probe's owned loopback listener was absent after its relay ended; unrelated processes were not stopped |
| VSIX packaging | `vsce package` produced an installable archive with runtime TOML dependency and its license; no SAS credentials, private config or Python environment is bundled |

Complete redacted tool records, positive/negative SAS logs and source hashes are in [validation/manifest.json](validation/manifest.json). Raw records stay private. The standard fixture's four expected ages provide the independent numerical check. This tests a small SAS program, not a scientific research pipeline.

Execution used an already configured Windows/Cygwin host and the book's existing isolated SASPy environment, with a private `SASPY_CFGFILE` and `SUBMISSION_PREFLIGHT_ENABLED=0`. The new launcher chose `SAS_ODA_AUTOLOAD_MACROS=0`; the complete environment distinctions are retained in the manifest. Credentials were not read by the extension or added to its configuration.

The first live test harness incorrectly expected a job-ID schema; the actual server returns a PID. The harness was corrected to poll that PID at 30-second intervals. Its subsequent complete positive and negative runs are the evidence published here. An initial extension-host attempt also inherited `ELECTRON_RUN_AS_NODE` from the agent shell; the test launcher now unsets it before starting the editor. Neither harness failure was represented as a successful SAS result.

Fresh Cygwin/Java installations were **not performed** on this already configured machine. macOS/Linux installer branches were inspected and are covered by the shared code's tests; they are not claimed as locally executed fresh installations. Cross-platform GitHub CI reports configuration/package tests separately. No interactive Copilot model turn, sign-in flow or current installation screenshot is claimed. Remote SSH, WSL, container and web-extension environments are excluded from this first guided release.

Official API references checked: [VS Code MCP extension API](https://code.visualstudio.com/api/extension-guides/ai/mcp), the actual [VS Code 1.142 API declarations](https://github.com/microsoft/vscode/blob/1.142.0/src/vscode-dts/vscode.d.ts), [extension packaging](https://code.visualstudio.com/api/working-with-extensions/publishing-extension), and [Codex MCP configuration](https://developers.openai.com/codex/mcp). The current guide's sample constructor differs from the installed API's positional constructor; this release uses the installed stable API.
