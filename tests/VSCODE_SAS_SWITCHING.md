# VS Code SAS switching: regression examples and debugging record

These checks preserve the debugging of ODA, local Windows SAS and Linux SAS
target selection. Run from the repository root. Install the extension's Node
dependencies first with `npm ci --ignore-scripts` in `integrations/vscode`.

## Offline tests

```bash
node tests/test_vscode_target_switch.cjs
```

This runs the real relay transport against a fake SAS backend and the setup
wizard/configuration tests. It covers Windows and Linux target restoration,
interpreter/configuration separation, stale assistant arguments, COM one-shot
defaults, and switching the same connected relay while an older job still
polls its original backend. The fake backend does not establish SAS execution.

For the full extension unit suite:

```bash
cd integrations/vscode
npm test
```

## Software detection without SAS execution

```bash
node tests/probe_vscode_sas_setup.cjs PATH_TO_RUNTIME_JSON
```

The installed runtime file is normally under VS Code's user global storage:
`User/globalStorage/chengzhongshan.mcp4sas/runtime.json`. Supply its actual
path for your operating system. This contains runtime/profile paths, not your
password. The probe reports bounded Python/SAS discovery and missing JARs;
it does not read authentication files or start SAS. Review local paths before
sharing a diagnostic report.

## Live same-connection switching

```bash
node tests/run_vscode_sas_switch_live.cjs --runtime PATH_TO_RUNTIME_JSON --out NEW_RESULTS_DIRECTORY
node tests/run_vscode_sas_switch_live.cjs --runtime PATH_TO_RUNTIME_JSON --out NEW_RESULTS_DIRECTORY --live
```

The first command discovers software and prints a plan. `--live` submits real
SAS through the current relay and your installed MCP4SAS backend. Both ODA and
local SAS must already be configured. A Windows host exercises local COM; a
licensed Linux host exercises Linux STDIO. Local SAS is not supplied by this
test. Use a new output directory to retain earlier attempts.

The test starts an ODA job, switches to local SAS, submits local positive and
intentional-error examples, polls the earlier ODA job, switches back, checks
recovery, and rejects a stale explicitly named target. Positive checks require
observed N=19, NMISS=0, minimum=11, maximum=16 and the correct host platform.
Intentional missing-dataset examples must fail. Saved code, complete SAS/MCP
records and diagnostics remain in the results directory. The installed user's
runtime file is checked byte for byte and is not changed by these tests.

On Windows, add `--iom-config PATH_TO_EXISTING_SASPY_CONFIG` to verify an
already working Windows IOM profile as well. This additionally saves a WORK
table and reads its value, 42, in the next submission. Only test-owned session
names and ports are used for cleanup; COM calls are one-shot.

## Real VS Code commands and terminal

```bash
node tests/run_vscode_extension_host.cjs --vscode PATH_TO_VSCODE_EXECUTABLE
node tests/run_vscode_extension_host.cjs --vscode PATH_TO_VSCODE_EXECUTABLE --runtime PATH_TO_RUNTIME_JSON --out HOST_RESULTS_JSON
```

The first command runs the extension-host checks without SAS. The second is an
opt-in live test: an isolated VS Code profile runs the actual Switch SAS Target
and Test Selected SAS command handlers for ODA/local/ODA. Picker choices are
automated; it is not an interactive AI model turn. The ordinary user profile,
credentials and selected SAS target are preserved. Omit `--vscode` to use the
test framework's downloaded VS Code. Linux CI needs a display such as Xvfb.

## Problems found and retained regression cases

1. The original relay captured the target at startup. It now rereads the saved
   selection for new requests and keeps older jobs associated with their owner.
2. Switching discarded target-specific configuration and could pick a local
   Python for ODA. A per-target cache restores the relevant interpreter,
   configuration, executable and session port.
3. A local `SASPY_CFGFILE` inherited from the parent could survive an ODA switch.
   Explicit selection now clears that incompatible inherited value.
4. COM was selected automatically while MCP defaulted to persistent execution.
   The relay now explicitly uses one-shot COM and explains its state limit.
   Existing IOM and Linux STDIO support keep their persistent behavior.
5. The first real-host check looked for observed values in CLI stdout. Some
   installed runners return only a compact output path there. Test Selected SAS
   now reads and verifies the actual saved SAS log.
6. A developer checkout without its installed Perl dependencies cannot start
   the backend. The live harness uses the configured installed runtime instead
   of silently treating every source checkout as installed. The first failed
   attempt is retained separately from the successful rerun.

Raw local evidence for the 15 November 2026 Windows/ODA trials is in
`SAS_Output_vscode_switch_20261115_r3/`. The first uninstalled-checkout attempt
is `SAS_Output_vscode_switch_20261115/`. Full logs and the original failed
host check are retained locally. Linux discovery/configuration and transport
behavior have offline tests; actual Linux SAS execution requires a separately
licensed Linux machine. Do not infer it from the Windows/ODA tests.
