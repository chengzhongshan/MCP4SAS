# Windows IOM and VS Code 0.1.5 validation — 2026-11-21

The plugin version remains **0.1.5**. This is a replacement build, not a new
version number. Tests were completed before updating GitHub.

## Problems corrected

- A saved runtime pointed to a deleted project. The local selection was repaired
  with a backup. The provider now handles missing runtime/project folders without
  advertising an unstartable server and shows **Repair SAS Setup**.
- PowerShell UTF-8 settings with a BOM are accepted. Malformed JSON leaves setup
  available instead of throwing during activation/provider discovery.
- New Windows targets now select Java IOM (`winlocal`) and generate a profile
  from the detected SAS installation. Explicit existing COM profiles are retained.
  Each remembered target keeps its own interpreter, profile and session port.
- Local Python provisioning no longer depends on winget or a manually installed
  Conda environment. A verified full Python.org installer is used when no
  compatible native interpreter is available. Broken managed venvs are detected
  by executing Python, retained as backups, and rebuilt.
- The connection-only probe converts a Windows executable path before launching
  it through Cygwin `sh`. Python script arguments keep the native path convention.
- Direct batch tools are hidden from MCP discovery by default. They remain an
  explicit `MCP4SAS_ENABLE_DIRECT_SAS_TOOLS=1` option.

## Observed results

| Check | Result |
|---|---|
| Node extension suite | 63 passed, 0 failed |
| SAS JAR setup suite | 6 passed, 0 failed |
| Real VS Code packaged extension activation | Passed; version 0.1.5 |
| Real process tasks | Success and intentional exit-17 failure handled correctly |
| Settings recovery | BOM, malformed JSON and missing runtime checks passed |
| Real Cygwin terminal | VS Code and Cygwin read/wrote the same test SAS file |
| Real VS Code ODA/local/ODA commands | Expected SASHELP.CLASS results observed |
| Real MCP target switching | Original pending job remained on its owning target |
| Fresh native Python setup | CPython 3.13.17 and SASPy 5.110.0 installed and used |
| Broken native venv recovery | Existing executable with missing base detected; backup and rebuild passed |
| Local IOM connection-only probe | PROC SETINIT completed successfully |
| Persistent state across MCP calls | WORK dataset, macro definition, macro variable, libref and option retained |
| Independent named sessions | WORK state remained isolated |
| Intentional SAS error | Reported FAILED; subsequent valid call succeeded in the same session |
| Background submit/poll | Final completed result observed |
| Relay restart | Named persistent SAS state remained available |
| Packaged relay with standalone Python | The same persistence checks passed |

The standard SASHELP.CLASS fixture returned 19 known ages, 0 missing, minimum
11 and maximum 16. Expected negative checks were deliberate and were followed by
successful recovery checks.

## Original macroparas preserved

The user's existing `macroparas.sas` was explicitly included with its original
helpers. It was not replaced or edited. The source SHA-256 before/after the test
was `f5a0edae59a7d4b36f267cd262faf216996d9b1d620c0deca4cc7ca300c6b594`.

The macro inspected `QueryGTEx4GeneID.sas` and produced its original styled HTML:
dark-blue bold Arial source on the light-blue background, with the source-path
title. A rendered browser screenshot was visually inspected. All source text
copied from the HTML matched the original after whitespace normalization and
compiled successfully in a separate local SAS session. The inspected GTEx macro
was **not executed** and no GTEx HTTP request was made.

`examples/sas_macros/macroparas_portable.sas` remains an optional example requiring
an explicit include. Neither setup nor the runner substitutes it for the user's
configured `macroparas.sas`.

## Reproduction

Use a new output directory for each live run. SAS must already be installed and
licensed. Runtime JSON is private; do not commit credentials or raw private logs.

```powershell
npm --prefix integrations/vscode ci --ignore-scripts
node --test integrations/vscode/test/*.test.js
python -m unittest discover -s integrations/vscode/test -p test_sas_jars.py -v
node tests/run_native_windows_setup_live.cjs local/native-validation-new
node tests/run_windows_iom_live.cjs --runtime private-runtime.json --out local/iom-validation-new --macros X:/your/library/Macros
node tests/run_vscode_sas_switch_live.cjs --runtime private-runtime.json --out local/switch-validation-new --live
npm --prefix integrations/vscode run package
```

`run_native_windows_setup_live.cjs` deliberately uses an empty discovered-Python
list, installs a real standalone CPython, creates a venv and installs actual
dependencies. It then corrupts only its own test venv's base path to exercise
recovery. It does not remove or alter an existing Conda installation.

For a packaged extension-host test, extract the VSIX into a new directory, copy
`test/host.cjs` under that extracted extension's `test/`, and set
`MCP4SAS_TEST_EXTENSION_PATH`, `MCP4SAS_TEST_HOST_PATH` and
`MCP4SAS_TEST_RUNTIME_REPO` before running `test/run-host.cjs`. The test module
must belong to the extracted extension so its VS Code API fixture is the same
API object used by that extension. `MCP4SAS_LIVE_SWITCH_RUNTIME` enables real
ODA/local/ODA commands in that isolated host profile.

## Scope

Live tests used Windows x64, SAS 9.4, VS Code 1.147.0 and SASPy 5.110.0. Native
Python was installed and exercised independently of Conda on this machine; this
was not a clean operating-system VM. No live licensed Linux/macOS SAS claim is
made. The installed editor was being updated, so extension-host testing used a
separate official VS Code build and isolated user profile. This verifies the
actual plugin and MCP/SAS execution, not an interactive Copilot model turn.
