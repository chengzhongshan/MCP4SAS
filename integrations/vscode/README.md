# MCP4SAS for VS Code

Perl and Python commands below are alternatives. After installation, the direct
Python runner finds its compatible project SASPy environment automatically.
See the [Python setup guide](../../MCP4SAS_Use_Python/README.md) for a separate
native environment. Use one runtime consistently for a persistent session.

Connect **GitHub Copilot or OpenAI Codex** to SAS without copying MCP configuration by hand.

[Watch the installation video](https://chengzhongshan.github.io/MCP4SAS/) for Windows setup, separate Copilot and Codex demonstrations, and macOS/Ubuntu instructions.

## Three steps

1. Download `mcp4sas-0.1.5.vsix` from the [MCP4SAS GitHub release](https://github.com/chengzhongshan/MCP4SAS/releases/tag/vscode-v0.1.5). In VS Code, open **Extensions → … → Install from VSIX…** and select it. Alternatively, run `code --install-extension mcp4sas-0.1.5.vsix`.
2. Run **MCP4SAS: Quick Setup** from the Command Palette. If no project is open, setup offers **Choose Project Folder** before installing anything. Open a folder you own and confirm VS Code's trust prompt if shown. Setup resumes in that folder; no manual restart is needed. Choose an existing MCP4SAS installation or let setup install it, then select Copilot, Codex, or both.
3. Refresh your assistant, allow its MCP server when prompted, and run **MCP4SAS: Check Connection**. Copy the offered SAS test prompt into the assistant to check actual SAS execution.

An interactive **Connect SAS to your AI assistant** walkthrough is also available on VS Code's Getting Started page. **MCP4SAS: Open Setup Guide** reopens this guide.

The **MCP4SAS Setup** page stays open with a checklist for the folder, Cygwin,
Java, GitHub source, libraries, SAS access and assistant connection. Long steps
show elapsed time every ten seconds; **Show installation log** opens the
detailed output. Cygwin can take more than five minutes. Its official progress
window is now visible too; keep it and VS Code open. Elapsed time means setup
is still being monitored, rather than an estimate of download completion.
Repeated Quick Setup clicks reuse the running flow. A failed step stays visible
with its error so you can fix the cause and continue.

## What setup does

### Where the scripts are installed

**Install MCP4SAS for this computer** downloads the GitHub source and installs
the scripts directly into the folder currently open in VS Code. With multiple
open folders, select the destination when asked. The same folder becomes the
SAS project and runtime, so you can run the Perl scripts in its Cygwin terminal.
You can open the folder yourself as shown in the video, or let Quick Setup
guide you through it. Installation starts only after a folder is open and
trusted. Existing complete MCP4SAS checkouts
are reused; Git history and unrelated files are preserved. Conflicting files
are reported before copying, rather than overwritten. The download does not
create a second Git repository inside an existing project.

On Windows, Quick Setup checks prerequisites before downloading source. Working
Cygwin packages are reused without upgrades. Missing packages are installed
from Windows before starting the Bash installer; if that Cygwin has active
processes, setup asks you to close them rather than terminating them to replace
DLLs. Installer output is saved under `local/install-logs/` in the project.
Failures show the exit code, log path and the last log lines in MCP4SAS Output.

From a terminal in that folder:

```bash
perl run_sas_codes_or_files_in_ODA.pl --code 'proc print data=sashelp.class; run;'
```

<details>
<summary>Python alternative</summary>

```bash
python run_sas_codes_or_files_in_ODA.py --code 'proc print data=sashelp.class; run;'
```

</details>

All existing commands, including **Open MCP4SAS Runtime Terminal**, login and
JAR setup, remain available. Earlier managed installations continue to work.
To switch one to the open folder, rerun Quick Setup and select **Install
MCP4SAS for this computer**. Your account setup and SAS requirements still apply.

### Default Cygwin terminal on Windows

After setup saves your runtime, a Cygwin terminal opens automatically in the
folder currently open in VS Code. Setup checks that VS Code can create a small
temporary file there and that Cygwin can read and update that same file, then
removes it. If either check fails, select a writable local folder with
**File → Open Folder**, or ask IT to grant your account access. The extension
does not change your folder permissions or require an administrator terminal.

New terminals use the open workspace folder, including when an older terminal
working-directory setting pointed elsewhere. This setting is saved only for
that workspace folder. **Open MCP4SAS Runtime Terminal** also follows the
current folder rather than reopening an older installation directory. With
multiple folders, it uses the active editor's folder or asks which folder to
open. Save your SAS file with **Ctrl+S** before submitting it; unsaved edits are
not yet on disk.

On a trusted local Windows workspace, the extension registers **MCP4SAS Cygwin** and selects it as the default terminal when a supported Cygwin installation is first detected or selected in Quick Setup. Portable installations use the same Cygwin directory you select for MCP4SAS. Open a **new terminal** to use it; existing terminals retain their shell. Bash starts interactively as a login shell, and `CHERE_INVOKING=1` keeps the terminal's project working directory.

Other terminal profiles are preserved. If you later select a different default using **Terminal: Select Default Profile**, the extension keeps your choice on subsequent launches. Run **MCP4SAS: Use Cygwin as Default Terminal** to switch back. To disable automatic configuration, set `mcp4sas.configureCygwinTerminal` to `false`. A workspace-specific default terminal setting can override the user default. macOS, Linux and remote windows retain their existing terminal settings.

| Host | Guided installation |
|---|---|
| Windows x64 | Detects `C:\cygwin64`, `C:\cygwin` or its own per-user Cygwin. You can also browse to a portable Cygwin `bin/perl.exe`. If missing, installs Cygwin with Git, Bash, Perl, Python/pip/headers, build and HTTPS tools **first**, before starting Bash. Detects Windows Java or offers Microsoft OpenJDK through winget/file selection, then runs `install/install_cygwin.sh`. Existing working packages are kept. |
| macOS | Runs `install/install_macos.sh` in a visible task terminal. Xcode Command Line Tools, Homebrew and its permissions remain platform prerequisites; follow a reported prerequisite and retry. |
| Ubuntu/Debian Linux | Installs Git through apt when missing, then runs `install/install_ubuntu.sh` in a visible task terminal; `sudo` may prompt there. Other Linux distributions should use an existing compatible installation. |

New MCP4SAS scripts are installed in the open workspace; launcher settings and optional private Python support are stored under VS Code's extension global storage. Existing installations are reused without Git reset, pull, or source edits. A failed installation is not reported as complete. Dependency downloads and compilation can take several minutes. The official MCP4SAS installers still install SASPy/Python dependencies; the extension adds no new Python programs.

For Copilot the extension uses VS Code's MCP definition-provider API. It does not rewrite `.vscode/mcp.json` or other Copilot servers. For Codex it adds only `[mcp_servers.mcp4sas_vscode]` in `$CODEX_HOME/config.toml` (normally `~/.codex/config.toml`), with a timestamped backup before any change. Conflicting entries or invalid TOML are refused, not replaced. Re-running Connect is idempotent. To stop advertising to Copilot, run Connect and choose Codex alone. To remove the Codex entry, remove the complete `BEGIN/END MCP4SAS VS CODE` block from that file.

## SAS access is still yours

### Fast completion and direct runner recovery

Short SASPy jobs now return their verified result in the initial MCP call,
waiting up to 20 seconds. Longer jobs return a PID; `wait_seconds: 0` retains
immediate background delivery. The relay reuses its backend between calls.
Full logs remain saved even when the response contains a shorter excerpt.

Direct Python and Perl runners remain available in the project terminal.
Use them for saved programs or when the server cannot start. If a request was
already forwarded, inspect its existing job before retrying through a runner:
a timeout may leave SAS running. The relay's recovery metadata distinguishes
these cases. See [measured timings, settings and safe recovery](../../docs/VSCODE_RUNNER_PERFORMANCE.md).

### Switch between ODA and local SAS

Click **SAS ODA**, **Windows SAS**, or **Linux SAS** in the status bar, or run
**MCP4SAS: Switch SAS Target**. Choose **SAS OnDemand for Academics** or
**SAS installed on this computer**. The extension finds Python automatically
and remembers each target's interpreter, profile and configuration. There are
no Python-path or configuration-file pickers in this switch.

After upgrading to this build, reload VS Code once to load the updated relay.
Subsequent switches take effect on the next assistant submission without
restarting Copilot or Codex. Jobs already submitted stay on their original
target and can still be polled. A request that explicitly names a different
target is rejected before SAS submission, preventing stale assistant settings
from silently sending code to the wrong system.

Select **Test SAS Now**, or run **MCP4SAS: Test Selected SAS**, to submit a
small SASHELP.CLASS check without an AI assistant. A verified result has 19
known ages, zero missing ages, minimum 11 and maximum 16. Read the saved SAS
log; finding software and discovering MCP tools are separate checks.

Existing terminals keep their old environment. Use **Open Runtime Terminal**
after switching for manual commands on the selected target. Existing SAS WORK
tables remain with the session/target that created them; switching does not
transfer those tables to another SAS environment.

Windows automatically configured COM uses **one-shot** submissions. Submit a
complete program in each call; WORK does not carry between calls. The relay
sets `persistent=false` for COM and rejects unsupported persistent requests.
An existing Windows IOM profile is preserved for persistent SAS work. On a
Linux desktop with licensed SAS installed, the same switch generates a local
STDIO profile using the detected SAS executable and supports named persistent
sessions. This does not install SAS or turn Windows WSL/SSH into a supported
local extension host.

Reusable checks and the debugging record are documented in
[tests/VSCODE_SAS_SWITCHING.md](../../tests/VSCODE_SAS_SWITCHING.md).

### Automatic SAS setup

Quick Setup finds the required Python environment, SASPy, installed SAS and
standard SAS encryption-file folders. You do not need to locate Python,
choose IOM versus COM, or select a SASPy configuration file.

If SAS is installed locally, setup asks one simple question: **SAS OnDemand
for Academics** or **SAS installed on this computer**. Without local SAS,
setup uses ODA. Run **MCP4SAS: Detect SAS Setup** to repeat detection, or click
the status-bar SAS target to switch. Your other extension commands remain available.

For Windows local SAS, setup detects native Windows Python with SASPy and
pywin32. If support is missing, visible installer tasks create a private
Python environment; Windows Python can be installed through winget when
needed. The generated local COM profile does not require an ODA account or
Java encryption files. Existing configured local IOM profiles are retained.
Linux local SAS uses its detected executable through STDIO. A licensed SAS
installation is still required; finding its executable does not verify the
license. macOS uses ODA or an existing supported remote configuration.

Detection checks the project environment, standard Python/Conda locations,
the Python launcher and PATH. It skips Windows Store launcher stubs and does
not scan entire drives. Broken interpreters are ignored. Cygwin Python links
are checked through the selected Cygwin Bash. Detection neither reads account
credentials nor starts SAS, and it runs during setup or an explicit rescan,
rather than before every submitted SAS program.

Existing custom SASPy configurations are retained. Advanced users can still
supply their established environment variables or use the original Perl CLI.
After changing the execution target, use **Test Selected SAS** to verify the
connection. The updated relay reads the selection before each new request;
software detection alone does not verify SAS execution.

### Company networks and SAS ODA

The standard SASPy ODA configuration uses **outbound TCP port 8591**. If your company network blocks that connection, contact IT/IS and ask
them to allow connections from your computer to the SAS ODA hostnames for
your account's home region. This is outbound access to SAS, rather than an
inbound listening port on your computer. Opening SAS Studio in a browser does
not test the SASPy connection. A timeout can have other causes; share the
actual connection error with IT/IS. See the
[official SAS ODA configuration](https://support.sas.com/ondemand/saspy.html)
for the region-specific hostnames and port.

### Missing credentials or SAS encryption files

Open Ctrl+Shift+P (Cmd+Shift+P on macOS):

- **MCP4SAS: Configure SAS ODA Login** opens a private installer task terminal
  using the selected runtime, Python environment and HOME. Enter credentials
  there, never in AI chat. The runner validates the login before saving it.
  A fresh Cygwin installation has its own home and may not find credentials
  from your Windows home. Missing-credential errors identify the file checked.
- **MCP4SAS: Configure SAS Encryption JARs** offers a downloaded ZIP or an
  extracted parent folder containing `sas.rutil.jar`, `sas.rutil.nls.jar`, and
  `sastpj.rutil.jar`. The setup page has **Open official SAS download** and
  **Select downloaded ZIP or folder** buttons. Obtain the files from the
  [official SAS download](https://support.sas.com/downloads/package.htm?pid=2494)
  using your own SAS Profile. After signing in, return to the download page if
  needed and follow SAS's download prompts and license terms. Select the ZIP
  in Downloads, or extract another archive format and select its folder.
  Inner folders are searched automatically. No manual Python activation or
  environment-variable command is needed for the guided ZIP/folder route.
  The helper validates all three JAR archives before copying them into the
  **selected** Python's SASPy environment, preserves changed originals, and
  refreshes an installer-managed static classpath when necessary. A custom
  profile is preserved; an explicit custom classpath may need updating.
  Detection also finds complete folders in Downloads/SAS-ODA-JarFiles or
  Downloads/SAS-ODA-Jars. Restart the assistant connection and
  old SAS sessions after changing the classpath, then retry a real SAS test.

**Check Connection** offers both setup actions after tool discovery. Discovery
alone does not prove the JARs or credentials are configured. The extension
does not request a password through the chat interface or download licensed
SAS libraries on your behalf.

Register for [SAS OnDemand for Academics](https://support.sas.com/en/software/ondemand-for-academics-support.html), or configure a supported licensed local SAS target. Complete the existing [MCP4SAS SASPy/authentication instructions](https://github.com/chengzhongshan/MCP4SAS#readme) privately. The extension never asks for, reads, sends to chat, or writes your SAS password. Installing this extension does not create an ODA account or complete SASPy authentication. Your Copilot/Codex account and organization's MCP policies also apply.

Discovery checks the MCP tools only. A useful first real submission is:

```sas
proc means data=sashelp.class n nmiss min max;
  var Age;
run;
```

For the standard fixture, verify **19 known ages, 0 missing ages, minimum 11, maximum 16**, along with a completed job and actual SAS log. Ask the assistant to poll a background job until it reaches a terminal state. Do not confuse a job-start acknowledgment with results.

## Automatic local-file and macro upload

The selected project folder becomes the MCP4SAS working directory. Recognized existing literal file references (such as `filename`, `infile` and `%include`) can be transferred to ODA automatically by the original runner. Put a macro named `%my_macro` in `Macros/my_macro.sas` inside that project. The editor launcher selects `SAS_ODA_AUTOLOAD_MACROS=0` so discovered local macros can be uploaded. It does not use the separate default remote macro-collection bootstrap. Dynamically constructed paths still require explicit preparation; missing local files are not invented. Manual SAS Studio uploads remain available.

Each client launch owns a separate loopback-only HTTP backend on an allocated port. A small stdio relay hides that detail from the client, discards the pinned server's notification response bodies, and relays SAS requests/results unchanged. You do not have to keep a server terminal open. Ending the client transport closes its owned HTTP backend. Finish or cancel SAS jobs using the original server tools before closing; the relay does not delete ODA files or promise to erase remote sessions.

The launcher uses VS Code's bundled Node/Electron runtime, so a separate Node installation is not required for installed users. New extension versions refresh stable launcher files when they activate in a trusted local workspace with a saved runtime. Keep the extension installed while using its Codex entry. Never configure both the provider and a second manual Copilot entry for the same backend unless that is intentional.

## Troubleshooting and scope

- **No tools:** trust your own local folder, refresh the chosen assistant, check enabled MCP tools, and inspect **Output → MCP4SAS** / the client's MCP output. Update VS Code if its MCP provider API is missing.
- **Portable Cygwin not detected:** use the existing-installation route and select its `bin/perl.exe`. Do not select Windows Strawberry Perl.
- **Tools discovered, SAS fails:** repair SASPy target, Java/IOM configuration and authentication. Discovery does not validate those.
- **Missing SAS Java classes or IOM JARs:** open the setup guide, use the official SAS download button, then select the downloaded SAS ZIP or its extracted folder. The guided helper finds the three files and uses the selected SASPy environment. The [Java troubleshooting guide](https://github.com/chengzhongshan/MCP4SAS/blob/main/docs/JAVA_SETUP_TROUBLESHOOTING.md) also retains the separate terminal instructions. Installing Java alone does not supply these SAS libraries.
- **Wrong relative path:** rerun Quick Setup and choose the actual project folder. The active editor file does not change the saved server folder automatically.
- **Restricted network:** installers need access to official Cygwin, GitHub,
  CPAN and Python/package mirrors. On Windows, Quick Setup combines Cygwin's
  public roots with the currently valid certificates in the Windows Trusted
  Root stores, verifies `https://cpanmin.us`, and passes that private bundle to
  Git, curl and the installer. This supports institution-managed TLS inspection
  without disabling certificate verification. If verification still fails,
  ask IT to install the institution's current root certificate in Windows;
  MCP4SAS never falls back to `curl -k`.
- **Remote VS Code:** SSH, WSL, containers and browser-based VS Code are not supported by this first guided desktop release. Configure their own MCP environment explicitly. Native Windows/Cygwin is a distinct route from WSL.
- **Platform evidence:** see [validation report](https://github.com/chengzhongshan/MCP4SAS/blob/main/integrations/vscode/VALIDATION.md). Shared code tests are not proof of fresh installations or interactive Copilot model execution on every OS.

## Build from source

Developers need Node 20+ and npm:

```bash
cd integrations/vscode
npm ci
npm test
npm run package
```

The output is `dist/mcp4sas-0.1.5.vsix` at the repository root. `npm run test:host` launches an isolated VS Code extension-host test; it does not install into your regular profile or change personal assistant settings.

This integration is independently maintained by the MCP4SAS author; it is not an official Microsoft, GitHub, OpenAI or SAS extension. New integration code has its own scoped MIT license; original repository code retains its existing rights.
