# VS Code installer: in-use Cygwin DLL recovery

15 November 2026. Extension version remains **0.1.5**.

The source copy succeeded. The next stage launched Cygwin setup with `-g`,
which requests upgrades to installed packages. It attempted to replace the
active `cygintl-8.dll`, received Permission denied, tried to terminate Cygwin
processes, and ended unsuccessfully. This was not evidence that the downloaded
MCP4SAS source or SAS account was invalid. The user's installed prerequisite
packages were already sufficient.

The [official Cygwin FAQ](https://cygwin.com/faq.html) describes `-g` as also
upgrading installed packages. The [Cygwin installation guide](https://www.cygwin.com/cygwin-ug-net/setup-net.html)
explains that active Cygwin processes should be closed before upgrades.

## Correction

- Probe required executables, Python/pip/development headers and certificates
  before the source download. Reuse an environment that already works.
- A fresh VS Code bootstrap installs the full prerequisite set from Windows.
  An existing runtime receives only missing packages, with active-process
  detection preventing an automatic DLL replacement in running sessions.
- The Bash installer does not launch Cygwin setup. Missing prerequisites get
  an actionable message; ordinary ready installations continue immediately.
- Use VS Code's built-in process task type. Match completion events to the
  returned TaskExecution, because VS Code can normalize away custom fields.
- Save the real installer output to project `local/install-logs/`; report the
  exit code, log path and last lines instead of a generic prerequisite error.

## Actual verification

The real installer in `C:/Users/cheng/OneDrive/Desktop/Test_MCP4SAS` completed
with exit 0, including SASPy/Java-classpath checks, Perl and server syntax,
and the existing installation smoke tests. Its installer script was backed
up before repair. No user processes were terminated during this recovery;
the only stopped processes were a verified isolated extension-test host tree.
The original Cygwin setup.log timestamp remained unchanged throughout the
successful project installation, confirming that the package upgrade was skipped.

All **41 Node tests** and **six shell regression checks** passed. A real isolated
Windows VS Code host passed ordinary process-task success, deliberate exit-17
failure, runtime-terminal file read/write in the open project, and existing
command/provider checks. An initial test incorrectly attempted to use the
Electron editor binary as a command-line Node task; its retained log was not
counted as passing. The corrected host test uses normal OS commands.

The new VSIX's packaged source files and production TOML dependency were
verified, and the real VS Code CLI successfully installed it with `--force`.
See [machine-readable evidence](../integrations/vscode/validation/installer-20261115.json).
Raw logs and the installer backup remain locally in the ignored
`SAS_Output_installer_dll_fix/` directory. This does not claim a new SAS ODA
login or a rerun of a scientific analysis. The new Cygwin SASPy environment
still gives normal SAS download guidance if proprietary encryption JARs are
missing; the user's configured existing Python environment is retained.

After updating the same-version extension, run **Developer: Reload Window**.
Then **MCP4SAS: Quick Setup** can reuse the existing project and prerequisites.
The project itself is already repaired and its installer has completed.
