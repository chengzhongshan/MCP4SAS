# VS Code ODA/local SAS switching — 23 November 2026

The 0.1.5 update passed actual ODA → local Windows IOM SAS → ODA execution
through the installed Desktop `Test_MCP4SAS` runtime. The real VS Code command
handlers and a connected MCP stdio/HTTP relay were tested separately.

## Changes

- Ordinary new project terminals now receive the selected profile, Python,
  configuration, Java selector and helper port. Previously only Open Runtime
  Terminal supplied the connection environment. Six explicit selectors are
  scoped to the open workspace; credentials, HOME and PATH are not copied.
- Saved helper ports now have a connection binding. Legacy/unbound targets
  receive a fresh port on selection; unchanged bound targets retain their own
  port. Old helper processes and their WORK tables are preserved.
- Test Selected SAS prints five CLASS rows as HTML, verifies 19 nonmissing
  ages with range 11–16, and checks the actual platform and WORK host. Correct
  statistics returned from the wrong SAS are rejected.
- The live relay regression now cleans only its own allocated helper PID
  trees. It never calls the legacy broad session-kill option or stops the
  user's helper on port 65055.

## Executed checks

| Check | Actual outcome |
|---|---|
| Extension Node regressions | 66 passed; 0 failed; 0 skipped |
| Real VS Code Switch SAS Target / Test Selected SAS | ODA / winlocal / ODA passed |
| Ordinary new Cygwin terminals after each selection | Correct profile, Python and config in all three |
| CLASS numerical results | N=19, missing=0, minimum=11, maximum=16 |
| Observed execution platforms | ODA Linux / Windows SAS / ODA Linux |
| CLASS HTML | Actual HTML retained for each host check |
| Connected MCP relay | Local/ODA positives and expected missing-dataset errors passed |
| Job ownership during switching | Original ODA job polled correctly after local selection |
| Stale explicit target argument | Rejected before SAS submission |
| Recovery following expected SAS errors | Passed |
| Test cleanup | Only the two owned helper PID trees were stopped |
| User's installed target settings | Unchanged by the test harnesses |

The user's original failing action did not include an exact error message.
The isolated connection checks succeeded before the changes as well; this
report does not assign the original failure to a single proven cause. It
records the independently identified terminal-propagation gap, migration of
legacy port records, and stronger execution checks.

The first isolated host attempt failed because its test PATH omitted Windows
PowerShell; that harness-only setup was corrected. Its original log remains
local. Later successful tests were run in fresh isolated VS Code profiles.

## How to use the installed update

1. Run **Developer: Reload Window** once after installing the rebuilt VSIX.
2. In the open `Test_MCP4SAS` folder, click the SAS status-bar item or run
   **MCP4SAS: Switch SAS Target**. Choose ODA or SAS installed on this computer.
3. Run **MCP4SAS: Test Selected SAS**. Check the actual result in Output → MCP4SAS.
4. For manual commands, open **Terminal → New Terminal** after switching.
   Alternatively use **MCP4SAS: Open MCP4SAS Runtime Terminal**. A terminal
   opened before the switch retains its old connection environment.

Assistant calls can omit `saspy_cfgname` to use the saved selection. A request
explicitly naming ODA while local SAS is selected is rejected rather than
silently redirected. Existing jobs remain associated with their original SAS.

## Evidence and limits

The [machine-readable record](../integrations/vscode/validation/switching-20261123.json)
contains source and log hashes, the three actual host checks, and every relay
result. Complete local SAS/HTML and protocol logs are in the ignored paths
recorded there. Reusable commands are documented in
[the regression guide](../tests/VSCODE_SAS_SWITCHING.md).

The implementation uses VS Code's
[workspace-scoped terminal environment API](https://code.visualstudio.com/api/references/vscode-api#GlobalEnvironmentVariableCollection).
Live licensed Linux SAS and interactive AI model turns were not tested here.
Linux discovery, profile generation and routing retain offline coverage.
The extension does not install SAS or change its licensing requirements.

## Installed package verification

The rebuilt VSIX was installed successfully into the normal Windows VS Code
profile with version **0.1.5**. Every installed `src` file was compared with the
maintained source. The actual installed package was then staged unchanged in an
isolated extension host and passed ODA → Windows IOM SAS → ODA, including the
three ordinary new-terminal environment checks and real CLASS HTML results.

The first package-only test used a UI-stubbing script outside the extension's
root. VS Code gave it a different API object, so it could not choose the
extension's target picker. The reusable host launcher now stages unchanged
package files and the harness under one isolated extension root. This test-only
failure and the successful rerun are retained separately. The successful host
also emitted nonfatal terminal-teardown diagnostics; its functional checks and
exit status passed.

The [post-install evidence](VSCODE_SAS_SWITCHING_20261123.json) records the VSIX
hash, verified package files and actual SAS logs. Reload your ordinary VS Code
window once before using the update. No automatic reload was forced during
this work, and your saved ODA/local configuration was preserved.

VSIX SHA-256: `3ecaea4b2717d31a6305e8f636a0b6b42aa1afb98f1dcfc863b943471eec6308`.
