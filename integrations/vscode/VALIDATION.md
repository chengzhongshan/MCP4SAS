# VS Code integration validation

## Updated 0.1.5 build — target switching and project terminals

23 November 2026. Ordinary new project terminals now inherit the selected
SAS target, Python and configuration. Connection-specific helper-port bindings
avoid attaching legacy targets to an old shared helper. Existing user sessions
are preserved. Test Selected SAS verifies returned host/platform and WORK,
prints CLASS HTML, and checks the expected age statistics.

All 66 Node extension tests passed. Real VS Code command handlers completed
ODA → Windows IOM SAS → ODA, including a fresh ordinary Cygwin terminal for
each selection. A connected MCP relay also passed original-job polling after
a switch, local/ODA successes and deliberate errors, stale-target rejection,
and recovery. The installed user selection was unchanged by the tests.
See the [full report](../../reports/VSCODE_SAS_SWITCHING_20261123.md) and
[machine-readable evidence](validation/switching-20261123.json). Linux local
SAS retains offline coverage; a live licensed Linux host was not tested.

## Updated 0.1.5 build — first-run setup guide

16 November 2026. Added a persistent setup checklist, ten-second elapsed-time
feedback, a visible official Cygwin progress window, folder-first continuation
after opening/trusting a project, and duplicate-click protection. The guided
SAS download accepts a ZIP or extracted parent folder and installs validated
files into the selected Python's SASPy. Recognized installer-managed static
classpaths are repaired with backups; custom configurations are preserved.

All 52 Node extension tests, six JAR-helper Python tests, 82 existing Python
runtime tests and 38 Java-guidance assertions passed locally. The isolated
real VS Code host passed command/provider/task checks and guide content
assertions. Native capture returned timeout errors; a separately rendered
browser preview was inspected and is not represented as an installation
screenshot. The six-minute progress test uses a simulated clock. See
[the first-run report](../../docs/FIRST_RUN_SETUP_REVIEW.md) and
[the validation record](validation/onboarding-20261116.json).

The video player page describes updated controls alongside the original MP4;
the MP4 itself was not regenerated. There was no fresh full Cygwin installation
or authenticated SAS download during these local UI checks. The existing
platform installation smoke check now includes the six JAR-helper tests.
Version remains 0.1.5.

## Updated 0.1.5 build — short-job completion and safe recovery

15 November 2026. The relay still reuses an owned backend. SASPy MCP tools now
wait up to 20 seconds for verified completion, with explicit immediate mode
and retained background jobs for longer analyses. Long response logs are
excerpted after full-log diagnosis. Relay errors distinguish requests that
were never forwarded from requests that may already be running; no timeout
automatically replays SAS through a CLI runner.

Local validation passed all 45 extension tests, 82 Python package tests and
60 standalone offline Perl test scripts. The isolated real VS Code host passed
activation, eleven commands, MCP provider registration, Electron Node launching
and installer-task success/failure reporting. Controlled live Windows SAS/COM
and ODA/IOM comparisons verified expected SASHELP output, native Python/Perl
CLI execution, bounded MCP completion, errors and explicit asynchronous mode.
The native Python MCP server also completed a successful and an intentionally
failing ODA submission. See the repository's
[performance report](../../docs/VSCODE_RUNNER_PERFORMANCE.md) and
[sanitized observations](../../docs/validation/plugin-latency-20261115.json).

This change did not repeat a fresh prerequisite installation or execute live
macOS/Linux SAS. It does not measure AI model tokens or claim that MCP speeds
up SAS computation. Version remains 0.1.5; reload VS Code after updating both
the extension and its configured MCP4SAS source.

## Updated 0.1.5 build — switching ODA and local SAS

15 November 2026. Added a clickable SAS target in the status bar, **Switch SAS
Target**, and **Test Selected SAS**. Target-specific interpreter/configuration
and session-port settings are preserved. The stdio relay rereads the selection
for new submissions; pending-job polls retain their original backend. Explicit
stale profile/configuration arguments are rejected before SAS submission.
Windows COM defaults to one-shot execution and rejects unsupported persistent
requests. Existing Windows IOM and Linux STDIO configurations remain supported.

All **41 Node tests passed**, including same-transport switching with a fake
SAS backend, Windows/Linux configuration separation, status-bar changes,
saved-log validation of compact CLI output, and COM persistence guards.
The real Windows VS Code host passed activation, eleven commands, MCP provider
and launcher checks, and shared VS Code/Cygwin workspace file access. Its actual
Switch SAS Target and Test Selected SAS commands successfully ran ODA/local/ODA;
all returned SASHELP.CLASS ages N=19, NMISS=0, minimum=11 and maximum=16.

The real stdio/HTTP relay also passed nine checks against the author's installed
MCP4SAS backend: Windows COM and ODA positive/negative jobs, polling an ODA job
after a local switch, switch-back/recovery, stale-target rejection, and Windows
IOM persistence. IOM saved value 42 in WORK and read it in the next submission.
Positive executions had zero SAS warnings and errors. Two deliberately missing
datasets produced the expected SAS errors. Installed user selection was unchanged
by the isolated tests; no AI model conversation is claimed.

Raw records are retained locally under `SAS_Output_vscode_switch_20261115_r3/`.
The initial uninstalled-checkout failure and the initial stdout-only host-check
failure are retained and explained in [the reproducible debugging examples](../../tests/VSCODE_SAS_SWITCHING.md).
Linux discovery, configuration restoration, environment isolation and transport
routing are covered offline. **Live licensed Linux SAS execution was not available
on this Windows workstation.** The same live harness can be run on a Linux SAS
host. Existing supported local desktop scope remains; WSL/SSH/container hosting
is not added by this change. Version remains **0.1.5**.

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

## Updated 0.1.5 build — Windows temporary cleanup

Temporary source cleanup uses asynchronous removal with five retries and reports denied cleanup as a warning. It cannot abort an otherwise successful source copy or replace the original installation exception. Removal is restricted to the installer-owned temporary prefix under the resolved temporary directory. All 17 Node tests passed, including simulated EPERM, original-error preservation and refusal of unrelated paths. The actual retained public source download copied successfully to an isolated test workspace with the runner present. No assertion is made that this repaired all possible pre-existing project conflicts.

## Updated 0.1.5 build — explicit SAS connection selection

14 November 2026. Added Select SAS Connection for ODA, Windows local IOM/COM, Linux local STDIO and a custom SASPy profile. Saved profile, optional configuration file and native Windows Python selection reach the relay and manual terminal. Changing the target allocates a separate session-server port so a previous Python interpreter is not silently reused. Restart the assistant connection and use a fresh session after changes. Discovery guidance now distinguishes ODA prerequisites from local SAS configuration.

The real installed VS Code extension-host test passed activation, all nine commands, MCP provider configuration and Electron/Node launcher checks in an isolated profile. All 18 Node tests pass, including the setup wizard's local/ODA switching, private-login guard, native Python selection, session-port isolation and environment propagation across all supported profiles. An actual Windows local IOM submission through the new runtime environment helper and the existing Perl runner completed with exit 0, zero SAS ERROR lines and zero WARNING lines. PROC MEANS on SASHELP.CLASS returned Age N=19, NMISS=0, MIN=11 and MAX=16. The test used an existing licensed SAS 9.4 installation and an existing private SASPy configuration; no SAS installation was performed. Full local records are retained in the evaluation workspace under MCP4SAS_POC_20261112/reports/local_connection_selector_1794672613743/. User ODA selection and credentials were not changed.

Windows COM, Linux STDIO and custom remote execution were not freshly executed for this change. Their configuration propagation is tested; this is not a claim of successful SAS execution on each platform. The universal desktop VSIX stays at the author's requested version 0.1.5.

## Updated 0.1.5 build ? automatic Python and SAS setup

14 November 2026. The manual Select SAS Connection command is replaced by Detect SAS Setup. Quick Setup detects project/Cygwin, PATH, standard Python/Conda and Windows Python-launcher environments; it asks only whether to use ODA or detected local SAS. Python and configuration-file pickers are removed from this flow. Existing installation, assistant integration, private login, JAR configuration, terminal and manual Perl execution features remain available. Detection does not run for every SAS submission.

All 28 Node tests pass. Regression coverage includes Windows Cygwin symlinks that raise EACCES through Windows stat, literal Bash argument passing, incomplete JAR folders, Windows Store stub exclusion, broken Python fallback, Linux SAS paths, macOS restrictions, ODA/local switching, existing IOM configuration preservation and private-venv dependency installation without modifying base Python. The real Windows VS Code extension host passed activation, nine commands and MCP provider/launcher checks.

Actual automatic discovery found the configured Cygwin project Python for ODA, native Anaconda Python with SASPy/pywin32 for Windows local SAS, a licensed Windows SAS installation and the downloaded SAS encryption folder. A generated local COM profile and the detected ODA environment each ran PROC MEANS on SASHELP.CLASS: N=19, NMISS=0, MIN=11, MAX=16; exit 0; zero SAS ERROR lines and zero WARNING lines. Existing saved user configuration and credentials were not changed by these tests. Complete logs/results are retained in the evaluation workspace at MCP4SAS_POC_20261112/reports/automatic_setup_20261114/.

Windows Python installation through winget and fresh missing-dependency installation were tested with task mocks, not freshly performed on this configured computer. Linux local SAS execution and macOS ODA execution were not freshly performed for this change. Automatic discovery searches bounded known locations, not every directory; nonstandard installations can still use the original CLI/environment configuration. SAS licensing, official SAS JAR downloads and private ODA login remain user prerequisites. Displayed extension version stays 0.1.5.

## Updated 0.1.5 build — writable project terminal

14 November 2026. On Windows, Quick Setup opens the runtime terminal automatically in the folder open in VS Code. Later calls follow the current workspace or active editor's folder, with a folder choice for ambiguous multi-root workspaces. The workspace terminal cwd is set to `${workspaceFolder}`; other projects' settings and manually chosen default profiles are preserved. CHERE_INVOKING=1 prevents the Cygwin login profile from returning to HOME.

Before installation and terminal creation, the extension checks real file access. It writes a uniquely named temporary file through the extension host; selected Cygwin Bash reads and updates that same file; the extension checks its contents and removes it. A failure explains how to choose a writable folder or request account access. The check does not change ACLs, elevate the terminal, or submit SAS code.

All 32 Node tests pass, including permission denial, mismatched file mapping, cleanup, current-folder switching, automatic terminal creation, portable Cygwin and prior setup regressions. The real installed Windows VS Code extension-host test passed: it opened a separate workspace with spaces and an apostrophe in its name, deliberately saved a different runtime cwd, opened the MCP4SAS terminal in the workspace, read a SAS file saved through VS Code's filesystem API, and appended to it through Cygwin. Nine commands, MCP provider and Electron/Node launcher checks also passed. The isolated host test ran outside the restricted filesystem sandbox; its launcher quotes the controlled workspace path for test-electron's Windows shell. Nonfatal editor/test-framework diagnostics are retained in the local test log.

Fresh Windows installation, macOS/Linux execution and scientific analyses were not rerun for this terminal-only change. The universal extension remains version 0.1.5.


## 15 November 2026 ? in-use Cygwin DLL installer recovery (0.1.5)

The user's setup.log reproduced an unnecessary gettext/libintl upgrade while
Cygwin programs were active. Replacing cygintl-8.dll failed with Permission
denied; setup tried to terminate processes and ended unsuccessfully. The source
copy itself succeeded. An unregistered custom task type also appeared in the
VS Code task log.

Quick Setup now probes working packages before cloning source, retains ready
Cygwin installations, installs only missing prerequisites from native Windows
when the runtime is idle, and never invokes the package manager from its own
Bash. Missing packages with active Cygwin processes produce a specific message
instead of terminating those processes. A fresh Cygwin bootstrap includes the
Python/pip/headers and build tools needed by the project installer.

Installer tasks use VS Code's built-in process type, match returned
TaskExecution handles (not a custom definition field that VS Code can remove),
and retain installer output and exit status under local/install-logs.

Actual checks:

- The read-only prerequisite probe found all packages ready on the user's
  existing Cygwin. The official setup log timestamp did not change during the
  repaired project installation.
- The actual Test_MCP4SAS installation finished with exit 0, including SASPy
  import, Java/classpath checks, Perl/server syntax and installation smoke
  tests. Existing account configuration was preserved. This is installation
  validation, not a new SAS ODA login or scientific-analysis run. The fresh
  Cygwin SASPy environment still reports the normal manual guidance for
  proprietary SAS encryption JARs; the extension retains the configured
  existing Python environment.
- All 41 Node tests passed, including existing portable-Cygwin setup, normalized
  task definitions, a logged exit-17 failure and the missing-package/busy-runtime
  guard. Six shell regression checks passed.
- A real isolated Windows VS Code extension host passed actual process-task
  success and exit-17 failure, Cygwin/project file read/write, command/provider
  activation and the launcher checks. An initial task test incorrectly used
  the Electron editor binary as a command-line Node executable; its log is
  retained. The corrected test uses normal OS commands and passed.

Evidence: local ignored SAS_Output_installer_dll_fix/ directory. The rebuilt
VSIX retains version 0.1.5; its current digest is in the release SHA256SUMS.
The main source/checkpoint and artifact publication are recorded in Git.

## 15 November 2026 - corporate TLS trust recovery (0.1.5)

Quick Setup reproduced Cygwin curl exit 60 while downloading `cpanmin.us` at a
site using Cloudflare Gateway TLS inspection. The presented certificate was
issued by a self-signed managed Gateway root that was valid and trusted by
Windows but absent from Cygwin's Mozilla-derived bundle. Python/SASPy setup had
already succeeded; the failure was isolated to the Perl dependency bootstrap.

The Windows extension now creates a private combined bundle from Cygwin's
public roots and currently valid certificates in the Windows Current User and
Local Machine Trusted Root stores. Existing user-provided CA variables take
precedence. Quick Setup verifies the CPAN bootstrap URL before cloning or
starting the installer and passes the bundle to Git, curl, `cpanm`, and the
installer task. The shared installer validates `MCP4SAS_CA_BUNDLE` and exports
the corresponding standard client variables. Certificate verification remains
enabled; there is no insecure fallback.

The generated bundle contained 167 certificates and successfully verified the
actual intercepted `cpanmin.us` connection with Cygwin curl 8.23.0. All 42 Node
tests and all 41 Perl-installer shell checks passed, including preservation of
custom CA settings, setup-task propagation, and rejection of a missing bundle.
An independent Windows-roots-only bundle also verified the intercepted URL,
without relying on any repaired Cygwin trust anchors. The real installation in
the affected Windows project completed with exit 0 and the final installation
smoke check passed, including Perl syntax, SASPy import, Java/classpath,
macro lifecycle, path handling, and archive transfer checks. The real VS Code
extension-host test passed activation, all eleven commands, MCP provider
registration, and built-in installer task success/failure reporting.
The rebuilt VSIX includes the PowerShell certificate helper and retains
version 0.1.5. These are installation and extension-host checks, not a new
authenticated live SAS ODA submission.
# Windows persistence revalidation — 2026-11-21

The replacement **0.1.5** build passed 63 Node tests, 6 SAS JAR tests, real packaged
VS Code activation and ODA/local/ODA commands. Real Windows IOM checks retained
WORK, macros, macro variables, librefs and options across calls and a relay
restart, including error recovery and isolated sessions. A real standalone
CPython install and broken-venv rebuild passed without using Conda or winget.
The original macroparas HTML was visually inspected and its copied source
compiled in a separate SAS session. See the [full validation record](../../docs/WINDOWS_IOM_VALIDATION_20261121.md)
for evidence, reproduction steps and scope. Plugin metadata remains 0.1.5.
