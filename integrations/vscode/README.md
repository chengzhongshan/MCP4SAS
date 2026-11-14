# MCP4SAS for VS Code

Connect **GitHub Copilot or OpenAI Codex** to SAS without copying MCP configuration by hand.

[Watch the installation video](https://chengzhongshan.github.io/MCP4SAS/) for Windows setup, separate Copilot and Codex demonstrations, and macOS/Ubuntu instructions.

## Three steps

1. Download `mcp4sas-0.1.5.vsix` from the [MCP4SAS GitHub release](https://github.com/chengzhongshan/MCP4SAS/releases/tag/vscode-v0.1.5). In VS Code, open **Extensions → … → Install from VSIX…** and select it. Alternatively, run `code --install-extension mcp4sas-0.1.5.vsix`.
2. Open a **local project folder** you trust. Run **MCP4SAS: Quick Setup** from the Command Palette. Choose an existing MCP4SAS installation or let setup install it. Select your SAS project folder, then Copilot, Codex, or both.
3. Refresh your assistant, allow its MCP server when prompted, and run **MCP4SAS: Check Connection**. Copy the offered SAS test prompt into the assistant to check actual SAS execution.

An interactive **Connect SAS to your AI assistant** walkthrough is also available on VS Code's Getting Started page. **MCP4SAS: Open Setup Guide** reopens this guide.

## What setup does

### Where the scripts are installed

**Install MCP4SAS for this computer** downloads the GitHub source and installs
the scripts directly into the folder currently open in VS Code. With multiple
open folders, select the destination when asked. The same folder becomes the
SAS project and runtime, so you can run the Perl scripts in its Cygwin terminal.
Open a folder before running Quick Setup. Existing complete MCP4SAS checkouts
are reused; Git history and unrelated files are preserved. Conflicting files
are reported before copying, rather than overwritten. The download does not
create a second Git repository inside an existing project.

From a terminal in that folder:

```bash
perl run_sas_codes_or_files_in_ODA.pl --code 'proc print data=sashelp.class; run;'
```

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
| Windows x64 | Detects `C:\cygwin64`, `C:\cygwin` or its own per-user Cygwin. You can also browse to a portable Cygwin `bin/perl.exe`. If missing, downloads setup from `cygwin.com` and installs a per-user Cygwin with Git, Bash, Perl and HTTPS tools **first**. Detects Windows Java or offers Microsoft OpenJDK through winget/file selection, then runs `install/install_cygwin.sh`. |
| macOS | Runs `install/install_macos.sh` in a visible task terminal. Xcode Command Line Tools, Homebrew and its permissions remain platform prerequisites; follow a reported prerequisite and retry. |
| Ubuntu/Debian Linux | Installs Git through apt when missing, then runs `install/install_ubuntu.sh` in a visible task terminal; `sudo` may prompt there. Other Linux distributions should use an existing compatible installation. |

New MCP4SAS scripts are installed in the open workspace; launcher settings and optional private Python support are stored under VS Code's extension global storage. Existing installations are reused without Git reset, pull, or source edits. A failed installation is not reported as complete. Dependency downloads and compilation can take several minutes. The official MCP4SAS installers still install SASPy/Python dependencies; the extension adds no new Python programs.

For Copilot the extension uses VS Code's MCP definition-provider API. It does not rewrite `.vscode/mcp.json` or other Copilot servers. For Codex it adds only `[mcp_servers.mcp4sas_vscode]` in `$CODEX_HOME/config.toml` (normally `~/.codex/config.toml`), with a timestamped backup before any change. Conflicting entries or invalid TOML are refused, not replaced. Re-running Connect is idempotent. To stop advertising to Copilot, run Connect and choose Codex alone. To remove the Codex entry, remove the complete `BEGIN/END MCP4SAS VS CODE` block from that file.

## SAS access is still yours

### Automatic SAS setup

Quick Setup finds the required Python environment, SASPy, installed SAS and
standard SAS encryption-file folders. You do not need to locate Python,
choose IOM versus COM, or select a SASPy configuration file.

If SAS is installed locally, setup asks one simple question: **SAS OnDemand
for Academics** or **SAS installed on this computer**. Without local SAS,
setup uses ODA. Run **MCP4SAS: Detect SAS Setup** to repeat detection or switch
between these choices later. Your other extension commands remain available.

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
After changing the execution target, restart the assistant MCP connection and
request a fresh-session SAS test. Actual results and the SAS log verify the
connection; software detection alone does not.

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
- **MCP4SAS: Configure SAS Encryption JARs** asks for the folder directly
  containing `sas.rutil.jar`, `sas.rutil.nls.jar`, and `sastpj.rutil.jar`.
  Obtain and extract them from the
  [official SAS download](https://support.sas.com/downloads/package.htm?pid=2494)
  using your own SAS Profile. Detection can find a complete extracted folder in Downloads/SAS-ODA-JarFiles or Downloads/SAS-ODA-Jars and run the helper automatically. The manual action remains available; it refuses missing/empty files and runs
  the existing JAR helper for the installer environment. Custom Python/profile
  classpaths must be updated separately. Restart the assistant connection and
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
- **Missing SAS Java classes or IOM JARs:** the extension does not bundle SAS proprietary JARs. Download the SAS-provided archive from the [official SAS download page](https://support.sas.com/downloads/package.htm?pid=2494), signing in with your own SAS Profile if requested. Extract it outside the repository. Locate `sas.rutil.jar`, `sas.rutil.nls.jar` and `sastpj.rutil.jar`, then set `MCP4SAS_SASPY_IOM_DIR` to their containing directory before running the MCP4SAS installer/configuration helper. Follow the [Java setup and troubleshooting guide](https://github.com/chengzhongshan/MCP4SAS/blob/main/docs/JAVA_SETUP_TROUBLESHOOTING.md) for the exact commands and configuration checks. Restart VS Code from the configured environment so its MCP subprocesses inherit your settings. Installing Java alone does not supply these SAS libraries.
- **Wrong relative path:** rerun Quick Setup and choose the actual project folder. The active editor file does not change the saved server folder automatically.
- **Restricted network:** installers need access to official Cygwin, GitHub, CPAN and Python/package mirrors. Follow institutional proxy rules; no TLS bypass is added.
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
