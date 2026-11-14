# MCP4SAS in Python

The independent Python runtime and utility port lives here. Executable Python
entry points are beside the corresponding Perl files, so you can choose a
runtime without moving your SAS programs. The Python runtime never launches
Perl. Existing Perl files and the VS Code extension's default runtime are unchanged.

Python **3.10 or later** is required. Use native Windows Python, macOS Python or
Linux Python. Native Windows execution does not need Cygwin. SAS ODA still needs
Java, the three SAS encryption JARs, your private SAS account and network access
on outbound TCP 8591. Local SAS requires its own licensed installation.

## Install in a separate Python environment

From the repository root, on Windows PowerShell:

```powershell
py -3 -m venv MCP4SAS_Use_Python/.venv
& ./MCP4SAS_Use_Python/.venv/Scripts/python.exe -m pip install -r MCP4SAS_Use_Python/requirements.txt
& ./MCP4SAS_Use_Python/.venv/Scripts/python.exe MCP4SAS_Use_Python/install.py
```

On macOS or Ubuntu:

```bash
python3 -m venv MCP4SAS_Use_Python/.venv
MCP4SAS_Use_Python/.venv/bin/python -m pip install -r MCP4SAS_Use_Python/requirements.txt
MCP4SAS_Use_Python/.venv/bin/python MCP4SAS_Use_Python/install.py
```

On Ubuntu, install `python3-venv` if Python reports that venv support is absent.
The configurator searches bounded standard Java/JAR locations and reuses your
existing files. If it cannot find the three encryption JARs, download and extract
them from [SAS](https://support.sas.com/downloads/package.htm?pid=2494), then rerun:

```text
python MCP4SAS_Use_Python/install.py --jars-dir /path/to/extracted/jars
```

Use the Python executable in the new environment for all commands below. Activate
that environment if you want to type simply `python`:

```powershell
./MCP4SAS_Use_Python/.venv/Scripts/Activate.ps1
```

```bash
source MCP4SAS_Use_Python/.venv/bin/activate
```

Activation is optional; if PowerShell blocks activation, use the full executable
path shown above. The generated credential-free configuration is stored under
`.saspy-config/` here. An explicit `--saspy-cfgfile` or `SASPY_CFGFILE` takes
precedence, so established private SASPy profiles can still be used.

## Run SAS without an AI agent

```bash
python run_sas_codes_or_files_in_ODA.py --code 'proc print data=sashelp.class; run;'
python run_sas_codes_or_files_in_ODA.py --file analysis.sas
python run_sas_codes_or_files_in_ODA.py --file analysis.sas --macro-dir /path/to/my/Macros
```

Local `%include` files, called local macros and their dependencies are inspected
recursively. The runtime uploads required source/data files, rewrites their
execution copies and leaves the originals unchanged. Multiple transfers use the
existing verified ZIP protocol. Conflicting upload basenames fail before a
transfer, rather than silently overwriting each other.

To preview the dependency plan without connecting to SAS:

```bash
python run_sas_codes_or_files_in_ODA.py --file analysis.sas --macro-dir /path/to/my/Macros --dry-run
```

If ODA credentials have not been configured, enter them privately:

```bash
python run_sas_codes_or_files_in_ODA.py --prompt-sas-oda-auth --check-saspy-connection-only
```

This saves an authinfo entry for the current user. Do not enter passwords in AI
chat or commit account files. `--check-saspy-connection-only` executes `PROC SETINIT`
against the chosen target; software detection alone does not verify SAS access.

To reuse WORK tables and macro definitions:

```bash
python run_sas_codes_or_files_in_ODA.py --session-id my_analysis --file prepare.sas
python run_sas_codes_or_files_in_ODA.py --session-id my_analysis --file plot.sas
python run_sas_codes_or_files_in_ODA.py --session-id my_analysis --kill-saspy-sessions
```

The session name implies persistence. Requests for one named session are
serialized. A wall-clock timeout terminates that runtime's backend/process tree;
user code is not automatically replayed. A later request starts a fresh session,
so WORK contents must be recreated.

## Use the Python MCP server

```bash
python server.py
```

This is a stdio MCP server. A client starts it rather than a person typing SAS
requests into its terminal. A manual HTTP alternative is:

```bash
python server.py daemon --host 127.0.0.1 --port 8081
```

Its Streamable HTTP endpoint is `http://127.0.0.1:8081/mcp`. Both transports use
the official Python MCP SDK. Four tool names are retained: the SASPy runner,
its compatibility alias, the fresh local-SAS runner and its compatibility alias.
Long-running jobs return a PID. Poll the PID for `COMPLETE`, `FAILED` or `UNKNOWN`;
a missing completion record is never treated as success. Full logs remain local.

For a separate VS Code Copilot connection, add a new server in `.vscode/mcp.json`
using **absolute paths**, for example:

```json
{
  "servers": {
    "mcp4sas-python": {
      "type": "stdio",
      "command": "C:/your/project/MCP4SAS_Use_Python/.venv/Scripts/python.exe",
      "args": ["C:/your/project/server.py"]
    }
  }
}
```

Merge this server with existing entries rather than replacing the file. On
macOS/Linux, use the environment's `.venv/bin/python` path. Keep the assistant's
working directory at your SAS project. The existing 0.1.5 extension continues to
register the Perl runtime; this port does not silently replace that connection.

## Utilities and original scientific examples

```bash
python examples/poc/run_example.py --list
python examples/poc/run_example.py --case clustergram --dry-run
python examples/poc/run_example.py --case clustergram
python examples/poc/run_example.py --case gene_gtf
python examples/poc/run_example.py --case oncoprint
python examples/poc/run_example.py --case forest
python examples/poc/run_example.py --case multi_gwas_gtf
python tools/profile_sas_source.py --repeat 3 analysis.sas
python tools/subset_gtex_expression.py --input expression.tsv.gz --genes 'CD55 TP53' --output subset.tsv
python cleanup_mcp4sas_intermediates.py --directory . --older-than-hours 24
```

The PoC programs and datasets are the original repository examples. Output
validators independently check exported numerical values; inspect figure
appearance separately. The cleanup command previews by default. `--apply`
removes only inactive, age-eligible directories with a valid ownership marker.

## Compatibility and validation scope

- This is the **runtime and utilities** port. Developer-only corpus generators
  and legacy test harnesses remain deferred, as agreed. See `PORT_INVENTORY.csv`.
- Python retains the public CLI operations, aliases, logs, source artifacts,
  persistent sessions, file operations and guarded directory-cleanup SAS code.
  Its internals are native Python APIs, not a line-for-line translation.
- Targeted macro loading is the Python default. Set
  `SAS_ODA_AUTOLOAD_MACROS=1` for the original load-all bootstrap. SAS macro
  functions do not trigger remote lookups.
- Code is preserved exactly; literal backslash-n characters are not implicitly
  converted into newlines. Use real newlines or `--code -` for standard input.
- The kill option closes only this Python session; it does not stop unrelated
  Perl/SASPy/Java processes. Result directories retain their reports and status
  records. Internal Perl worker flags are not public Python options.
- HTTP is SDK-managed Streamable HTTP, not Mojolicious. Keep it on loopback;
  this local code-execution server is not configured for public hosting.
- Exact source versions and reused Python/SAS assets are recorded in
  `SOURCE_PROVENANCE.json`. The original repository's licensing applies.

Run the offline tests with the configured Python:

```bash
python -m unittest discover -s MCP4SAS_Use_Python/tests -v
```

They include frozen behavior captured from the original Perl modules, actual
Python backend subprocesses and real MCP clients over stdio and HTTP. These
offline checks do not require SAS credentials. Opt-in live checks and full
scientific example execution are separate:

```bash
python MCP4SAS_Use_Python/tests/run_live_validation.py --outdir MCP4SAS_Use_Python/test-results/my-validation --figures
```

Choose a new output directory. Complete submitted SAS, logs and results are
retained there and excluded from Git. See `VALIDATION.md` for observed results
and limitations; no scientific, platform or speed claim follows merely from
successful packaging.
