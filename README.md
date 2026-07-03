# MCP4SAS

MCP4SAS is a small Model Context Protocol (MCP) package for running SAS code
through SASPy. It can use SAS OnDemand for Academics (SAS ODA), local SAS on
Linux, or local Windows SAS when those targets are configured in SASPy. It
includes:

- `server.pl`: an HTTP MCP server exposing SASPy-backed SAS tools.
- `run_sas_codes_or_files_in_ODA.pl`: a command-line SASPy runner. The file
  name keeps historical ODA wording for compatibility.
- `RunLocalSASDirectly.sh`: an optional direct local SAS batch helper for
  running Linux SAS or Windows `sas.exe` without SASPy.
- `RunWindowsSAS.sh`: a compatibility wrapper around `RunLocalSASDirectly.sh`.
- `MCPDeps/SAS_ODA_Runner.pm`: the Perl/Python bridge around SASPy.
- `MCPDeps/sas_oda_session_server.py`: a persistent local SASPy session
  server for faster repeated SAS ODA calls.
- `MCPDeps/importallmacros_ue.sas`: helper for loading SAS macros from
  the SAS ODA `~/Macros` directory.

This repository is intentionally SAS-focused. It does not include the
MultiGWAS-Explorer GWAS plotting pipeline.

## Requirements

- A SAS OnDemand for Academics account, a local SAS installation, or a licensed
  remote SAS IOM server.
- Perl 5.
- Python 3.8 or newer.
- Java Runtime Environment, required by SASPy IOM.
- Network access to SAS ODA when using the `oda` config.

The install scripts create a repo-local Python virtual environment named
`.venv-pipeline` and install Perl modules under `local/perl5`.

## Configure SASPy Target

MCP4SAS uses SASPy configuration names to choose the SAS target. ODA remains the
default. Local SAS users should select a local config explicitly.

Create a repo-local SASPy config template:

```bash
bash install/install_saspy_config.sh
```

If you already have `~/sascfg_personal.py` but want MCP4SAS to use the repo
template with ODA and local SAS examples, force a repo-local copy:

```bash
MCP4SAS_OVERWRITE_SASPY_CONFIG=1 bash install/install_saspy_config.sh
```

MCP4SAS searches these config files in order:

```text
./sascfg_personal.py
~/.config/saspy/sascfg_personal.py
~/sascfg_personal.py
```

Select a target with `SASPY_CFGNAME` or `--saspy-cfgname`.

SAS ODA:

```bash
SASPY_CFGNAME=oda ./run_sas_codes_or_files_in_ODA.pl --check-sas-oda-login-only
```

Local Linux SAS:

```bash
SASPY_CFGNAME=linuxlocal \
MCP4SAS_LOCAL_SAS_PATH=/opt/sasinside/SASHome/SASFoundation/9.4/bin/sas_u8 \
./run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only
```

`MCP4SAS_LOCAL_SAS_PATH` must point to the local `sas` or `sas_u8` executable.
This Ubuntu computer does not have local SAS installed, so the `linuxlocal`
config is available but cannot connect until SAS is installed.

Local Windows SAS through SASPy IOM:

```bash
SASPY_CFGNAME=winlocal ./run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only
```

On Cygwin or other Windows shells, set `SASPY_JAVA` if Java is not on `PATH`.
For example:

```bash
SASPY_CFGNAME=winlocal \
SASPY_JAVA='/cygdrive/c/Program Files/Java/jdk-11/bin/java.exe' \
./run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only
```

Remote licensed IOM servers can use `iomlinux` or `iomwin` with
`SASPY_IOMHOST`, `SASPY_IOMPORT`, and `SASPY_IOM_AUTHKEY`.

## Direct Local SAS Without SASPy

MCP4SAS also exposes `run_local_sas_without_saspy` for users who want to run an
installed local SAS executable directly. This tool does not use SASPy. It starts
a fresh Linux SAS or Windows `sas.exe` batch process for each call through
`RunLocalSASDirectly.sh` and then polls the operating-system PID.

For Linux SAS:

```bash
export MCP4SAS_LOCAL_SAS_EXE='/opt/sasinside/SASHome/SASFoundation/9.4/bin/sas_u8'
```

For Windows SAS from Cygwin/MSYS:

```bash
export MCP4SAS_WINDOWS_SAS_EXE='/cygdrive/c/Program Files/SASHome/SASFoundation/9.4/sas.exe'
```

Then start MCP4SAS and call `run_local_sas_without_saspy` from the agent:

```bash
perl server.pl daemon -m production -l http://127.0.0.1:8080
```

You can also pass `local_sas_exe` and optionally `local_sas_platform` (`linux`
or `windows`) as MCP tool arguments.

Important limitation: this direct batch tool is not persistent. Each tool call
launches a new SAS process, so `WORK` data sets, macro variables, librefs,
options, and loaded macros do not carry over to the next call. The PID polling
only tracks whether the current batch job is still running.

If you need persistent local SAS state, use the SASPy-backed runner instead:

```bash
SASPY_CFGNAME=linuxlocal ./run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only
SASPY_CFGNAME=winlocal   ./run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only
```

Feasibility note: persistent local SAS without SASPy is possible only by adding
a resident session manager that starts SAS once, sends multiple code blocks to
the same process, marks log/listing boundaries, handles interrupts and
timeouts, and shuts the process down cleanly. That is a larger design than the
current batch helper. For now, SASPy `linuxlocal`, `winlocal`, or another SASPy
configuration is the recommended persistent-session path.

## Install On Ubuntu Or Linux

```bash
git clone https://github.com/chengzhongshan/MCP4SAS.git
cd MCP4SAS
bash install/install_ubuntu.sh
```

If system packages are already installed, skip `apt`:

```bash
MCP4SAS_SKIP_APT=1 bash install/install_ubuntu.sh
```

## Install On macOS

Install Xcode Command Line Tools when prompted, then run:

```bash
git clone https://github.com/chengzhongshan/MCP4SAS.git
cd MCP4SAS
bash install/install_macos.sh
```

The macOS installer uses Homebrew for Perl/Python/Java support.

## Install On Windows With Cygwin

Open a Cygwin terminal, then run:

```bash
git clone https://github.com/chengzhongshan/MCP4SAS.git
cd MCP4SAS
bash install/install_cygwin.sh
```

If you already installed the required Cygwin packages, skip the package update:

```bash
MCP4SAS_SKIP_CYGWIN_SETUP=1 bash install/install_cygwin.sh
```

## Install With Conda

This is useful on Linux, macOS, WSL, or a Unix-like shell with Conda available:

```bash
git clone https://github.com/chengzhongshan/MCP4SAS.git
cd MCP4SAS
bash install/install_conda.sh
```

By default this creates a Conda environment named `mcp4sas`. To choose another
name:

```bash
MCP4SAS_CONDA_ENV=my_sas_env bash install/install_conda.sh
```

## Use With Vagrant

From a machine with Vagrant and VirtualBox installed:

```bash
git clone https://github.com/chengzhongshan/MCP4SAS.git
cd MCP4SAS
vagrant up
vagrant ssh
cd /vagrant
bash install/install_ubuntu.sh
```

This gives Windows and macOS users a clean Ubuntu runtime without modifying the
host system.

## First SAS ODA Login

SAS ODA now requires the SAS IOM encryption jars used by SASPy:

```text
sas.rutil.jar
sas.rutil.nls.jar
sastpj.rutil.jar
```

SASPy documents this requirement for SAS ODA/SAS 9.4M7 here:
https://sassoftware.github.io/saspy/configuration.html#sas-iom-client-encryption-jars

If you already have MultiGWAS-Explorer checked out with the Java supplement
files, install the jars into MCP4SAS with:

```bash
MCP4SAS_MULTIGWAS_ROOT=/path/to/MultiGWAS-Explorer \
  bash install/install_saspy_iom_jars.sh
```

In this workspace, for example:

```bash
MCP4SAS_MULTIGWAS_ROOT=/mnt/24921E0E921DE4D8/Scripts_Lib/MultiGWAS-Explorer-main/MultiGWAS-Explorer \
  bash install/install_saspy_iom_jars.sh
```

Or point directly to the directory containing the three jars:

```bash
MCP4SAS_SASPY_IOM_JAR_DIR=/path/to/MultiGWAS-Explorer/install/saspy-java-supplement/java/iomclient \
  bash install/install_saspy_iom_jars.sh
```

Interactive credential setup:

```bash
./run_sas_codes_or_files_in_ODA.pl --prompt-sas-oda-auth --check-sas-oda-login-only
```

Noninteractive credential setup:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --sas-oda-account you@example.com \
  --sas-oda-password 'your-password' \
  --check-sas-oda-login-only
```

Credentials are saved in the SASPy authinfo file after validation with
`proc setinit;run;`.

## Run SAS Code From The Command Line

Simple code:

```bash
OPEN_RESULT=0 ./run_sas_codes_or_files_in_ODA.pl \
  --code "proc print data=sashelp.class(obs=5); run;" \
  --persistent \
  --session-id demo
```

Run a `.sas` file:

```bash
OPEN_RESULT=0 ./run_sas_codes_or_files_in_ODA.pl \
  --file my_program.sas \
  --persistent \
  --session-id demo
```

Run code from standard input:

```bash
printf '%s\n' \
  'data a;' \
  'input a @@;' \
  'datalines;' \
  '10 20' \
  ';' \
  'run;' \
  'proc print data=a;' \
  'run;' |
OPEN_RESULT=0 ./run_sas_codes_or_files_in_ODA.pl \
  --code - \
  --persistent \
  --session-id demo
```

Long SAS job:

```bash
OPEN_RESULT=0 ./run_sas_codes_or_files_in_ODA.pl \
  --file long_job.sas \
  --run-timeout-seconds 7200 \
  --persistent \
  --session-id long_job
```

Disable the wrapper timeout:

```bash
OPEN_RESULT=0 ./run_sas_codes_or_files_in_ODA.pl \
  --file very_long_job.sas \
  --no-run-timeout \
  --persistent \
  --session-id long_job
```

Stop wedged local SASPy/SAS ODA helper processes:

```bash
./run_sas_codes_or_files_in_ODA.pl --kill-saspy-sessions
```

## Upload, Download, Delete, And List ODA Files

Upload:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --upload-file local.csv \
  --persistent \
  --session-id demo
```

List remote files:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --dir4listing '~/Macros' \
  --persistent \
  --session-id demo
```

File info:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --file-info '~/myfile.csv' \
  --persistent \
  --session-id demo
```

Download:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --download-file '~/result.csv' \
  --download-local-path ./result.csv \
  --persistent \
  --session-id demo
```

Delete:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --delete-file '~/old_result.csv' \
  --persistent \
  --session-id demo
```

## SAS Macro Loading

By default, if submitted SAS code calls non-built-in macros, MCP4SAS loads
macros from SAS ODA `~/Macros` through `importallmacros_ue.sas`.

Useful behavior:

- Reusing `--persistent --session-id <id>` avoids repeating expensive bootstrap
  work on every command.
- If the local `importallmacros_ue.sas` helper already matches the remote copy
  in SAS ODA `~` by size and timestamp, upload is skipped.
- If local macro files are newer than matching SAS ODA `~/Macros/*.sas` files,
  the local copy can be uploaded and included after the global macro bootstrap.

Useful environment variables:

```bash
SAS_ODA_AUTOLOAD_MACROS=1
SAS_ODA_MACRO_BOOTSTRAP_TIMEOUT_SECONDS=420
SAS_ODA_CLIENT_HEARTBEAT_SECONDS=20
```

The waiting heartbeat includes elapsed time, for example:

```text
Waiting for SAS ODA session server response while reading response header (elapsed=60s, timeout=3675s)...
```

## Run The MCP Server

```bash
perl server.pl daemon -m production -l http://127.0.0.1:8080
```

The MCP endpoint is:

```text
http://127.0.0.1:8080/mcp
```

Keep this terminal open while the AI agent is using MCP4SAS. For a persistent
background service on Linux, you can use `nohup`:

```bash
nohup perl server.pl daemon -m production -l http://127.0.0.1:8080 \
  > mcp4sas.server.log 2>&1 &
```

Stop the server by pressing `Ctrl-C` in the server terminal, or by killing the
background process:

```bash
pkill -f 'server.pl daemon.*127.0.0.1:8080'
```

Tools exposed:

- `run_sas_codes_or_files_in_ODA`
- `run_sas_codes_or_script_in_ODA`, compatibility alias
- `run_local_sas_without_saspy`, direct one-shot Linux/Windows SAS batch runner
  without SASPy or persistent session reuse
- `run_sas_codes_or_script_on_local_Windows`, compatibility alias for the direct
  local SAS tool

Example MCP tool arguments:

```json
{
  "sas_codes_or_file": "proc print data=sashelp.class(obs=5); run;",
  "persistent": "1",
  "session_id": "demo"
}
```

For long jobs, the first MCP call returns a PID. Poll later with:

```json
{
  "pid": 12345
}
```

Poll long-running SAS jobs no more than about every 30 seconds. MCP4SAS starts
SAS work in a background process so the AI agent does not need to hold one MCP
request open for the whole SAS runtime.

## Minimal JSON-RPC Smoke Test

In one terminal:

```bash
perl server.pl daemon -m production -l http://127.0.0.1:8080
```

In another terminal:

```bash
curl -s http://127.0.0.1:8080/mcp \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'
```

You should see the tools `run_sas_codes_or_files_in_ODA`,
`run_sas_codes_or_script_in_ODA`, `run_local_sas_without_saspy`, and
`run_sas_codes_or_script_on_local_Windows`.

## Configure AI Agents

MCP4SAS is an HTTP MCP server. Start `server.pl` first, then point your AI
agent's MCP configuration to:

```text
http://127.0.0.1:8080/mcp
```

Keep the server on `127.0.0.1` unless you know how to secure it. The tools can
run SAS code and perform SAS ODA file operations, so do not expose this endpoint
to an untrusted network.

### Codex

OpenAI Codex supports MCP servers in the CLI and IDE extension. Codex stores MCP
configuration in `config.toml`; by default this is `~/.codex/config.toml`, and a
trusted project can also use `.codex/config.toml`. See the official Codex MCP
documentation: https://developers.openai.com/codex/mcp

Recommended CLI setup:

```bash
codex mcp add mcp4sas --url http://127.0.0.1:8080/mcp
```

Manual `~/.codex/config.toml` setup:

```toml
[mcp_servers.mcp4sas]
url = "http://127.0.0.1:8080/mcp"
tool_timeout_sec = 120
default_tools_approval_mode = "prompt"
enabled = true
```

Then start or restart Codex:

```bash
codex
```

Inside the Codex terminal UI, use:

```text
/mcp
```

to confirm that `mcp4sas` is available. In the Codex IDE extension, open MCP
settings or the shared `config.toml` and use the same server definition.

Example prompt for Codex:

```text
Use the MCP4SAS tool to run:
proc print data=sashelp.class(obs=5); run;
Use session_id demo and check the result when the job finishes.
```

### Gemini CLI

Gemini CLI uses a JSON settings file for MCP server configuration. Google
codelab material shows `.gemini/settings.json` as the project-level settings
file and uses `mcpServers` to define MCP tools; for an HTTP MCP server, the
Gemini example uses `httpUrl`. See:
https://codelabs.developers.google.com/cloud-gemini-cli-mcp-go

Create or edit `.gemini/settings.json` in your project, or edit the user-level
Gemini settings file if you want MCP4SAS available globally:

```json
{
  "mcpServers": {
    "mcp4sas": {
      "httpUrl": "http://127.0.0.1:8080/mcp"
    }
  }
}
```

Restart Gemini CLI after changing the settings:

```bash
gemini
```

Then ask Gemini to list or use the MCP4SAS tools. Example prompt:

```text
Use the mcp4sas MCP server to submit this SAS code to SAS ODA:
proc print data=sashelp.class(obs=5); run;
Use a persistent session named demo.
```

If your Gemini CLI build only supports command-based stdio MCP servers, use a
separate HTTP-to-stdio MCP proxy or upgrade Gemini CLI to a build that supports
HTTP MCP configuration.

### Ollama And Other Local LLM Clients

Ollama itself is a local model runtime, not an MCP client. To use MCP4SAS with
an Ollama model, run Ollama behind an MCP-capable client or bridge. Examples of
this pattern include local agent shells, desktop chat clients, or gateway tools
that support MCP servers and can route tool calls to an Ollama-backed model.

General pattern:

```bash
ollama serve
ollama pull qwen2.5-coder:7b
perl server.pl daemon -m production -l http://127.0.0.1:8080
```

Then configure your MCP-aware Ollama client with:

```json
{
  "mcpServers": {
    "mcp4sas": {
      "url": "http://127.0.0.1:8080/mcp"
    }
  }
}
```

Some clients use `url`, some use `httpUrl`, and older clients only support
stdio-style MCP servers. For stdio-only clients, add an HTTP-to-stdio MCP proxy
between the client and `http://127.0.0.1:8080/mcp`, or use a client that
supports streamable HTTP MCP servers directly.

Good local-model prompts should be explicit because smaller local models may
not infer polling behavior:

```text
Use MCP4SAS to run this SAS code in SAS ODA:
proc means data=sashelp.class; var height weight; run;
If the first tool call returns a PID, wait and poll with that PID later.
Do not poll more often than every 30 seconds.
```

### Other MCP Clients

For any MCP client that supports streamable HTTP servers, use:

```text
name: mcp4sas
url:  http://127.0.0.1:8080/mcp
```

For clients that require stdio servers, use an HTTP-to-stdio MCP proxy or wrap
the MCP4SAS HTTP endpoint with the proxy recommended by that client. MCP4SAS
itself should continue running as the HTTP service shown above.

## Recommended Agent Workflow

1. Start MCP4SAS:

```bash
cd MCP4SAS
perl server.pl daemon -m production -l http://127.0.0.1:8080
```

2. In the AI agent, call `run_sas_codes_or_files_in_ODA` with SAS code or a
   local `.sas` file.
3. If the response contains a PID, wait at least 30 seconds before polling.
4. Poll with `{"pid": <PID>}` until the job completes.
5. Ask the agent to inspect the returned `output.html.info.txt` path if the SAS
   log contains errors or warnings.
6. Reuse `session_id` for related calls so WORK tables and loaded macros stay
   available.

For direct local Linux or Windows SAS without SASPy, call
`run_local_sas_without_saspy` instead. Do not expect persistent state between
calls; combine dependent SAS steps in one submitted program, or use
`saspy_cfgname=linuxlocal` or `saspy_cfgname=winlocal` with the SASPy-backed
tool.

## MCP Server Security Notes

- Bind to `127.0.0.1` for local use.
- Do not expose MCP4SAS on a public interface without authentication and network
  controls.
- Prefer interactive SAS ODA credential setup instead of pasting passwords into
  AI prompts.
- If you use `sas_oda_password` through an MCP call, treat the conversation and
  logs as sensitive.
- Review agent-generated SAS code before running it against sensitive data.

## Troubleshooting

If SASPy hangs or a persistent session becomes stale:

```bash
./run_sas_codes_or_files_in_ODA.pl --kill-saspy-sessions
```

If the log says `No SAS process attached` together with
`An exception was thrown during the encryption key exchange`, SASPy reached the
SAS ODA Java/IOM bridge but SAS ODA did not create a usable SAS session. The
most common cause is that the three SAS IOM encryption jars are missing from
SASPy's `java/iomclient` directory. Copy them from MultiGWAS-Explorer:

```bash
MCP4SAS_MULTIGWAS_ROOT=/path/to/MultiGWAS-Explorer \
  bash install/install_saspy_iom_jars.sh
```

Then refresh or validate the saved SAS ODA credentials:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --prompt-sas-oda-auth \
  --check-sas-oda-login-only
```

Also confirm that your SASPy config file is visible. MCP4SAS searches these
locations, in order:

```text
./sascfg_personal.py
~/.config/saspy/sascfg_personal.py
~/sascfg_personal.py
```

You can force a specific config file or config name:

```bash
SASPY_CFGFILE=~/sascfg_personal.py \
SASPY_CFGNAME=oda \
./run_sas_codes_or_files_in_ODA.pl --check-sas-oda-login-only
```

If the jars are installed and credentials are correct but the same error
remains, check that the `iomhost` entries in `sascfg_personal.py` match your SAS
ODA home region and try Java 8 or Java 11, depending on what your local
SASPy/ODA setup supports.

If a command completes but the browser prints noisy errors, suppress auto-open:

```bash
OPEN_RESULT=0 ./run_sas_codes_or_files_in_ODA.pl --code "proc print data=sashelp.class;run;"
```

If Python packages fail on older systems, make sure Python is at least 3.8.
Current `Pillow` and `saspy` releases require modern Python.
