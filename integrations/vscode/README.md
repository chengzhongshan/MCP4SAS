# MCP4SAS for VS Code

Connect **GitHub Copilot or OpenAI Codex** to SAS without copying MCP configuration by hand.

## Three steps

1. Download `mcp4sas-0.1.0.vsix` from the [MCP4SAS GitHub release](https://github.com/chengzhongshan/MCP4SAS/releases/tag/vscode-v0.1.0). In VS Code, open **Extensions → … → Install from VSIX…** and select it. Alternatively, run `code --install-extension mcp4sas-0.1.0.vsix`.
2. Open a **local project folder** you trust. Run **MCP4SAS: Quick Setup** from the Command Palette. Choose an existing MCP4SAS installation or let setup install it. Select your SAS project folder, then Copilot, Codex, or both.
3. Refresh your assistant, allow its MCP server when prompted, and run **MCP4SAS: Check Connection**. Copy the offered SAS test prompt into the assistant to check actual SAS execution.

An interactive **Connect SAS to your AI assistant** walkthrough is also available on VS Code's Getting Started page. **MCP4SAS: Open Setup Guide** reopens this guide.

## What setup does

| Host | Guided installation |
|---|---|
| Windows x64 | Detects `C:\cygwin64`, `C:\cygwin` or its own per-user Cygwin. You can also browse to a portable Cygwin `bin/perl.exe`. If missing, downloads setup from `cygwin.com` and installs a per-user Cygwin with Git, Bash, Perl and HTTPS tools **first**. Detects Windows Java or offers Microsoft OpenJDK through winget/file selection, then runs `install/install_cygwin.sh`. |
| macOS | Runs `install/install_macos.sh` in a visible task terminal. Xcode Command Line Tools, Homebrew and its permissions remain platform prerequisites; follow a reported prerequisite and retry. |
| Ubuntu/Debian Linux | Installs Git through apt when missing, then runs `install/install_ubuntu.sh` in a visible task terminal; `sudo` may prompt there. Other Linux distributions should use an existing compatible installation. |

A new MCP4SAS checkout is stored under VS Code's extension global storage. Existing installations are reused without Git reset, pull, or source edits. A failed installation is not reported as complete. Dependency downloads and compilation can take several minutes. The official MCP4SAS installers still install SASPy/Python dependencies; the extension adds no new Python programs.

For Copilot the extension uses VS Code's MCP definition-provider API. It does not rewrite `.vscode/mcp.json` or other Copilot servers. For Codex it adds only `[mcp_servers.mcp4sas_vscode]` in `$CODEX_HOME/config.toml` (normally `~/.codex/config.toml`), with a timestamped backup before any change. Conflicting entries or invalid TOML are refused, not replaced. Re-running Connect is idempotent. To stop advertising to Copilot, run Connect and choose Codex alone. To remove the Codex entry, remove the complete `BEGIN/END MCP4SAS VS CODE` block from that file.

## SAS access is still yours

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

The launcher uses VS Code's bundled Node/Electron runtime, so a separate Node installation is not required for installed users. New extension versions refresh stable launcher files the next time Quick Setup runs. Keep the extension installed while using its Codex entry. Never configure both the provider and a second manual Copilot entry for the same backend unless that is intentional.

## Troubleshooting and scope

- **No tools:** trust your own local folder, refresh the chosen assistant, check enabled MCP tools, and inspect **Output → MCP4SAS** / the client's MCP output. Update VS Code if its MCP provider API is missing.
- **Portable Cygwin not detected:** use the existing-installation route and select its `bin/perl.exe`. Do not select Windows Strawberry Perl.
- **Tools discovered, SAS fails:** repair SASPy target, Java/IOM configuration and authentication. Discovery does not validate those.
- **Wrong relative path:** rerun Quick Setup and choose the actual project folder. The active editor file does not change the saved server folder automatically.
- **Restricted network:** installers need access to official Cygwin, GitHub, CPAN and Python/package mirrors. Follow institutional proxy rules; no TLS bypass is added.
- **Remote VS Code:** SSH, WSL, containers and browser-based VS Code are not supported by this first guided desktop release. Configure their own MCP environment explicitly. Native Windows/Cygwin is a distinct route from WSL.
- **Platform evidence:** see [validation report](https://github.com/chengzhongshan/MCP4SAS/blob/feature/vscode-guided-setup/integrations/vscode/VALIDATION.md). Shared code tests are not proof of fresh installations or interactive Copilot model execution on every OS.

## Build from source

Developers need Node 20+ and npm:

```bash
cd integrations/vscode
npm ci
npm test
npm run package
```

The output is `dist/mcp4sas-0.1.0.vsix` at the repository root. `npm run test:host` launches an isolated VS Code extension-host test; it does not install into your regular profile or change personal assistant settings.

This integration is independently maintained by the MCP4SAS author; it is not an official Microsoft, GitHub, OpenAI or SAS extension. New integration code has its own scoped MIT license; original repository code retains its existing rights.
