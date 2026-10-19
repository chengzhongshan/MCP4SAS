@echo off
setlocal
where code >nul 2>nul
if errorlevel 1 (
  echo VS Code command not found. Open VS Code, choose Extensions, then Install from VSIX.
  echo Download: https://github.com/chengzhongshan/MCP4SAS/releases/tag/vscode-v0.1.0
  pause
  exit /b 1
)
set "MCP4SAS_VSIX=%TEMP%\mcp4sas-0.1.0.vsix"
powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; $base='https://github.com/chengzhongshan/MCP4SAS/releases/download/vscode-v0.1.0/'; Invoke-WebRequest ($base+'mcp4sas-0.1.0.vsix') -OutFile $env:MCP4SAS_VSIX; $s=(Invoke-WebRequest ($base+'SHA256SUMS') -UseBasicParsing).Content; $m=[regex]::Match($s,'(?m)^([a-fA-F0-9]{64})\s+\*?mcp4sas-0\.1\.0\.vsix\s*$'); if(-not $m.Success -or (Get-FileHash -LiteralPath $env:MCP4SAS_VSIX -Algorithm SHA256).Hash -ne $m.Groups[1].Value){throw 'Release checksum mismatch'}"
if errorlevel 1 (
  echo Download or checksum verification failed. No extension was installed.
  pause
  exit /b 1
)
call code --install-extension "%MCP4SAS_VSIX%"
if errorlevel 1 exit /b 1
echo Open your SAS folder in VS Code, then run MCP4SAS: Quick Setup.
pause
