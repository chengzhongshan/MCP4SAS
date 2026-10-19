# Runnable VSIX installer checks

19 October 2026, Windows x64.

- Downloaded the published `mcp4sas-0.1.0.vsix` from GitHub independently. SHA-256 matched `f4b87a288ab10b7bcb965c272013183a001001bd60f01740f1a09ceef5f36cf2`.
- Ran `install_vscode_extension.sh` under Cygwin. Actual GitHub VSIX/checksum downloads and verification succeeded. A CLI capture shim received `--install-extension` and the temporary VSIX path.
- Ran `install_vscode_extension.cmd` under Windows Command Prompt/Windows PowerShell. Actual GitHub downloads and verification succeeded. The CLI capture shim received the expected install argument and quoted temporary VSIX path.
- Separately installed the actual VSIX with the real VS Code CLI in an isolated profile. The installed extension list reported `chengzhongshan.mcp4sas@0.1.0`.

The first CMD test failed because Windows PowerShell exposed the checksum response as binary content. The installer now downloads SHA256SUMS to a file and reads it explicitly as text before comparing hashes. The corrected script was rerun successfully. The published CMD asset contains this fix; the extension package itself did not change.

These are download/checksum/CLI-dispatch tests and a separate actual VSIX installation. They are not fresh Cygwin/Java installations, macOS/Linux fresh-runtime tests or an interactive Copilot conversation. Main extension/SAS evidence is in `integrations/vscode/VALIDATION.md`.
