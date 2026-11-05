# Local Windows SASPy IOM authentication investigation: 2026-11-04

The local Java IOM failure was traced to an incorrect service principal name
(SPN) caused by reverse loopback name resolution. A forward lookup of localhost
alone did not reveal it. No remote Workspace Server was intended or tested.

**Resolved and verified on 2026-11-04:** after the hosts entries were consolidated,
a fresh native Windows Python process connected successfully using the original
`C:/Users/cheng/sascfg_winlocal_sasjava.py` profile named `winlocal`. SASPy reported
access method **IOM**, SAS 9.4 TS1M5 and SASPy 5.104.0. It printed two
SASHELP.CLASS observations, emitted the actual runtime marker
`WINLOCAL_RETEST_PASS`, closed the session and exited zero. The final log ends
with `RETEST_COMPLETE: PASS`. Evidence is retained in the parent workspace at
`SAS_Output_windows_iom_sspi_20261104/winlocal_retest_20261104_161847.txt`.
This retest used the original Java profile without an explicit-SPN bridge patch
or a COM substitution.

## Decisive evidence

Testing used the actual Windows `cheng` account, rather than the separate agent
sandbox account. Windows Python is `C:/Users/cheng/anaconda3/python.exe`, SASPy
is 5.104.0, and installed local SAS is 9.4 TS1M5. The account token reports
CloudAP, but independent signed/encrypted Windows loopback NTLM handshakes passed
for HOST/localhost, HOST/computer-name, SAS/localhost and SAS/computer-name.
CloudAP or a missing password could not be established as the cause.

The original Java IOM connection reproduced:

```text
The security package failed while authenticating a user.
```

A minimal Java zero-config probe exposed the underlying exception hidden by
SASPy's concise error reporting:

```text
com.sas.security.sspi.SSPIAuthException: SEC_E_NO_CREDENTIALS
```

Targeted SAS SSPI logging then showed the actual bad target:

```text
machineName 127.0.0.1 resolved to IP address /127.0.0.1
IP address kubernetes.docker.internal/127.0.0.1 resolved to kubernetes.docker.internal
SSPIAuth.<init>(NTLM,null,SAS/kubernetes.docker.internal,127.0.0.1,...)
loaded sspiauth
```

The hosts file has three separate IPv4 loopback entries, with
`kubernetes.docker.internal` first. Java resolves localhost forward to 127.0.0.1,
but reverse resolution of the numeric address selects the Docker alias. The
local IOM bridge authenticates against that derived SPN. The `-zero` mode still
launches local installed SAS; its temporary loopback port is normal local IOM
behavior.

In the same Java probe, setting only `ZeroConfigWorkspaceServer.setSPN` to
`SAS/localhost` made the connection succeed and execute `JAVA_ZERO_PASS`.
Forcing IPv4 alone still failed. This comparison isolates the SPN rather than
Java bitness, the account's general ability to use NTLM, or a remote server.

| Control | Result |
| --- | --- |
| Native Windows loopback authentication, four targets | Passed using NTLM |
| Local COM workspace | SAS code executed successfully |
| Original local SASPy Java IOM profile | Failed, SEC_E_NO_CREDENTIALS |
| SAS-supplied SSPI JAR before SASPy's JAR | Same failure |
| Complete SAS-supplied client JAR set | Same failure |
| Explicit x64 sspiauth_wx6 DLL | Same failure |
| Negotiate instead of default local NTLM | Same failure |
| IPv4 preference alone | Same failure |
| Explicit SAS/localhost SPN alone | Java IOM connected and executed SAS code |
| SASPy local COM with the saved profile below | Passed |

SAS's bundled Java is 64-bit 1.7.0_161. The Oracle Java on the original PATH is
32-bit 1.8.0_381; the diagnostic used the explicit bundled x64 runtime. The native
SSPI DLL loaded successfully, and versioned SAS COM registrations point to the
installed executable with `-objectserver`. Re-registration and DLL copying did
not address the observed wrong-SPN condition and are not proposed as this fix.

## Prepared repair for the original Java IOM path

Consolidate the current separate IPv4 loopback entries into one line, keeping
localhost first and preserving the computer name and Docker alias:

```text
127.0.0.1 localhost YOUR-COMPUTER-NAME kubernetes.docker.internal
```

Preserve any additional existing loopback aliases on that same line. Leave all
other mappings unchanged. This follows SAS's guidance about a single loopback
line with localhost first. The relevant distinction here is reverse resolution,
even though forward resolution already appeared correct.

The investigation workspace contains an encoding-preserving, preview-first
repair script at
`SAS_Output_windows_iom_sspi_20261104/Repair-LocalSasLoopback.ps1`, relative to
the parent workspace containing MCP4SAS. It preserves aliases/comments, checks
the current file against a backup before writing, saves the original bytes,
verifies the written file and clears the DNS cache. The generated
`hosts.proposed` is available for review there.

From that parent workspace:

```powershell
# Preview: no system write.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SAS_Output_windows_iom_sspi_20261104\Repair-LocalSasLoopback.ps1

# Apply from an Administrator PowerShell window.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\SAS_Output_windows_iom_sspi_20261104\Repair-LocalSasLoopback.ps1 -Apply
```

The execution-policy switch affects only this PowerShell process. It does not
change Windows authentication policy. This investigation had a non-administrator
token, so it prepared the proposal without applying it. Consequently, the
initial diagnosis therefore left the original SASPy Java profile pending a
retest. That subsequent retest has now passed, as recorded at the top of this
report; the current hosts file contains the proposed single loopback line.

After applying the repair, start a fresh native Windows Python process and
retest the original local profile. No iomhost, remote port, username or password
should be added to turn this into a remote configuration.

## Verified local SASPy connection available now

`install/sascfg_windows_local_com.py` provides an explicit local COM alternative:

```python
SAS_config_names = ['winlocal_com']
winlocal_com = {'provider': 'sas.iomprovider', 'encoding': 'windows-1252'}
```

From the MCP4SAS directory in a regular PowerShell window:

```powershell
$cfg = (Resolve-Path .\install\sascfg_windows_local_com.py).Path
& "$env:USERPROFILE\anaconda3\python.exe" -c "import saspy; s=saspy.SASsession(cfgfile=r'$cfg',cfgname='winlocal_com'); print(s.submit('proc print data=sashelp.class(obs=2);run;')['LOG']); s.endsas()"
```

This exact saved configuration was tested successfully with native Windows
Python, pywin32 and SASPy 5.104.0. It launched local SAS, read two SASHELP.CLASS
observations and closed its own workspace. Existing Java winlocal profiles were
not changed or silently redirected to COM.

Raw probes, captured exceptions, the hosts proposal and successful connection
logs are retained in the parent workspace's
`SAS_Output_windows_iom_sspi_20261104` directory. Security event-log reading was
not available to this non-administrator process; no event-based conclusions
were drawn. No account password, authentication policy, registry value or
installed SAS/SASPy binary was changed.

References: [SAS local-loopback support note 55227](https://support.sas.com/kb/55/227.html),
[SASPy configuration](https://sassoftware.github.io/saspy/configuration.html),
[SASPy IOM troubleshooting](https://sassoftware.github.io/saspy/troubleshooting.html),
[Microsoft NTLM InitializeSecurityContext](https://learn.microsoft.com/en-us/windows/win32/secauthn/initializesecuritycontext--ntlm).

## Persistent local Windows sessions from Cygwin

Use the same native Python and winlocal configuration environment for both
commands. The canonical runner's `--help` now includes a two-command `mc1`
example that creates WORK.A and reads it on a second submission.

A persistent startup failure mentioning `E:\mnt\e\...sas_oda_session_server.py`
was caused by an unconverted Cygwin helper path. The persistent launcher now
converts that path for the selected Python, as well as explicit session temp
paths and local file-transfer request paths. Remote SAS paths are preserved.
Live validation created five WORK rows and read them on the next submission,
with SAS PID 37624 unchanged. The HTML was saved successfully; no one-shot
fallback was enabled. Raw transcript: parent workspace
`SAS_Output_windows_iom_sspi_20261104/persistent_paths.txt`.
