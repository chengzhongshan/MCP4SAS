# MCP4SAS

MCP4SAS is a small MCP package for running SAS code through SAS OnDemand for
Academics (SAS ODA). It includes:

- `server.pl`: an HTTP MCP server exposing SAS ODA tools.
- `run_sas_codes_or_files_in_ODA.pl`: a command-line SAS ODA runner.
- `DiffGWASDeps/SAS_ODA_Runner.pm`: the Perl/Python bridge around SASPy.
- `DiffGWASDeps/sas_oda_session_server.py`: a persistent local SASPy session
  server for faster repeated SAS ODA calls.
- `DiffGWASDeps/importallmacros_ue.sas`: helper for loading SAS macros from
  the SAS ODA `~/Macros` directory.

This repository is intentionally SAS-focused. It does not include the
MultiGWAS-Explorer GWAS plotting pipeline.

## Requirements

- A SAS OnDemand for Academics account.
- Perl 5.
- Python 3.8 or newer.
- Java Runtime Environment, required by SASPy IOM.
- Network access to SAS ODA.

The install scripts create a repo-local Python virtual environment named
`.venv-pipeline` and install Perl modules under `local/perl5`.

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

## Start The MCP Server

```bash
perl server.pl daemon -m production -l http://127.0.0.1:8080
```

The MCP endpoint is:

```text
http://127.0.0.1:8080/mcp
```

Tools exposed:

- `run_sas_codes_or_files_in_ODA`
- `run_sas_codes_or_script_in_ODA`, compatibility alias

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

## Troubleshooting

If SASPy hangs or a persistent session becomes stale:

```bash
./run_sas_codes_or_files_in_ODA.pl --kill-saspy-sessions
```

If a command completes but the browser prints noisy errors, suppress auto-open:

```bash
OPEN_RESULT=0 ./run_sas_codes_or_files_in_ODA.pl --code "proc print data=sashelp.class;run;"
```

If Python packages fail on older systems, make sure Python is at least 3.8.
Current `Pillow` and `saspy` releases require modern Python.
