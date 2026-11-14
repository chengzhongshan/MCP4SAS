# VS Code integration validation

## 0.1.2 — Cygwin default terminal

Windows setup now registers an interactive login Bash profile using the selected Cygwin installation and chooses it as the user default once. `CHERE_INVOKING=1` preserves the terminal working directory. Automatic activation can also configure an already detected Cygwin installation. Later manual default-profile choices are retained; an explicit command can restore Cygwin. Other profile entries, macOS/Linux and remote windows remain unaffected. Automatic configuration can be disabled with `mcp4sas.configureCygwinTerminal=false`.

The 14 Node tests include profile preservation, portable Bash paths, one-time default selection, explicit reselection, opt-out and remote-window exclusion. The Windows extension-host test verifies real VS Code settings updates. Supplying `MCP4SAS_TEST_CYGWIN_PERL` to `npm run test:host` additionally opens a new default terminal, executes a Bash marker command and verifies its project working directory. This optional check passed locally on VS Code 1.145.3 with real portable Cygwin. The harness waits for the asynchronous profile cache to refresh before creating a terminal. Fake executable fixtures used on CI do not claim shell execution.

## 0.1.1 — 11 November 2026

Local checks used Node 24.14.0 and the real Windows VS Code 1.145.3 extension host in a temporary profile. All **14 Node tests passed**, including the complete Quick Setup command with a simulated portable Cygwin installation, saved project/runtime configuration and Copilot selection. The real host activated all four commands, registered both empty and configured MCP providers, verified their launcher arguments, environment and working directory, and launched VS Code's bundled Electron as Node. Personal editor and assistant settings were not changed.

The actual stdio relay and original Perl backend also passed initialization, notification suppression, tool discovery and clean shutdown. Two programs ran against the existing local Windows SAS `winlocal` profile: `SASHELP.CLASS` returned known=19, absent=0, youngest=11, oldest=16 with COMPLETE status; an intentionally missing dataset returned FAILED with the expected SAS error. Raw records and logs remain in the local `SAS_Output_vscode_validation_20261111` directory outside the repository. These checks used an already configured SAS/Java/Cygwin installation; they do not claim a fresh installation or an interactive AI conversation.

The first CI host run passed on Windows and Linux but exposed test-electron 2.5.2 using the removed macOS `Electron` executable alias. The test launcher now reads the actual `CFBundleExecutable` from the downloaded app bundle, with a regression test. Fixed portable Perl selection being discarded after installation and initialization errors waiting for the discovery timeout. Client/provider versions now follow the extension package version. The VSIX builds successfully. CI now runs real extension-host checks on Windows, macOS and Linux (under Xvfb), in addition to unit tests and packaging, and reruns when shared backend/install files change. CI results must be checked separately from the local results above.

Reproduce from `integrations/vscode`:

```bash
npm ci --ignore-scripts
npm test
npm run test:host  # Linux without a desktop: xvfb-run -a npm run test:host
npm run package
# Optional: private runtime.json contains repo, perl and cwd paths.
# SASPY_CFGFILE and SASPY_CFGNAME select your privately configured SAS target.
node test/live-smoke.cjs /private/runtime.json /private/capture.json --sas
```

## 0.1.0 — historical validation

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

## 0.1.3 — Cygwin HTTPS helper recovery

Reproduced Git exit 128 with the user's newly installed Cygwin and inherited PATH. The identical public GitHub ls-remote request passed when that Cygwin bin directory was prepended. Setup now applies this environment to Cygwin bootstrap, clone, path conversion, installer tasks and runtime startup. Certificate and proxy settings remain unchanged. All 15 Node tests pass. One universal desktop VSIX supports Windows, macOS and Ubuntu; no platform-specific binary is required. New macOS/Ubuntu fresh installations were not performed locally.

## 0.1.4 — installer task launch

Installer tasks now use VS Code ProcessExecution with separate executable/argument values. Previously ShellExecution launched the native Windows Bash path inside the default Cygwin shell, which removed backslashes and caused exit 127. The setup regression mock rejects ShellExecution and verifies ProcessExecution. This also applies to Java and platform installer tasks. The prior Cygwin PATH fix is retained.

## 0.1.5 — missing SAS prerequisites

Added private-terminal ODA login and SAS JAR folder configuration commands. Discovery now offers these setup actions explicitly. Missing-credential CLI errors name the checked credential file and private terminal recovery command; Java encryption diagnostics point to the editor JAR action and official SAS download. Tests exercise missing and complete JAR folders, selected login HOME/profile, absence of password arguments and actual CLI failure without credentials. No passwords or SAS libraries are packaged.

## 0.1.6 — expose managed source and manual execution

Setup reports the managed GitHub source/runtime path separately from the selected SAS project. Added Open MCP4SAS Runtime Terminal, preserving the selected environment and opening at the scripts. Source validation now rejects checkouts missing the Perl submission runner, including immediately after clone. Regression coverage checks a checkout missing that runner, the source-vs-project terminal location and the selected Bash/HOME. Existing managed source was inspected and contains server.pl, the runner and installer scripts; no claim was made that the project folder itself is the source checkout.
Actual manual-route check: the managed runtime's own Perl executable and runner submitted proc print data=sashelp.class; run; to the configured ODA target with exit 0, no SAS ERROR lines and an HTML result. Local records are retained outside the repository at MCP4SAS_POC_20261112/reports/manual_runner_20261114. All 15 Node tests passed.

## Updated 0.1.5 build — open-workspace installation

At the author's request, the displayed version remains 0.1.5. New installations download source into the folder open in VS Code, retain existing features, validate essential scripts, preserve unrelated files and Git history, and refuse conflicting files before copying. Source is staged in a unique temporary folder and validated before copying; temporary clone metadata is excluded. Existing-runtime setup remains supported. The updated release checksum and commit distinguish this build from the earlier 0.1.5 release asset.
