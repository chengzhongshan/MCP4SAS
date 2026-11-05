# Local SAS home directories and Linux STDIO

For local SAS, `--dir4local_sas_home DIR` makes `~` refer to DIR for listing,
uploads, downloads, file information and deletion. The directory is created if
needed. Recognized profiles `winlocal`, `winlocal_com`, `linuxlocal`, `local`
and `stdio` default to the run's HTML output directory. An explicit option or
`SAS_LOCAL_HOME_DIR` also enables this behavior for a custom local profile.
The `oda` profile keeps its online home; remote IOM/SSH sessions reject the
local-home setting. For local profiles with custom names, supply the option.

The runner configures the SAS HOME fileref, HOME environment value, _USERHOME
and PIPELINE_SAS_HOME macro variables. It expands quoted `~` and `~/...` SAS
literals outside comments, inline records and macro-quoted text. Examples:

```sas
libname saved '~';
data saved.class; set sashelp.class; run;
filename report '~/report.txt';
data _null_; file report; put 'Local SAS output'; run;
```

For computed paths or macro parameters, use `%superq(PIPELINE_SAS_HOME)` or
`%sysfunc(pathname(HOME))`. The runner does not rewrite arbitrary unquoted SAS
expressions or source files loaded at runtime by `%include`; those files can
use these HOME values directly. Ordinary SAS string values beginning with the
same quoted shorthand are also expanded. WORK datasets keep their normal SAS
session lifetime.

## Windows SAS from Cygwin

After selecting your working Windows Python and `winlocal` configuration:

```bash
perl run_sas_codes_or_files_in_ODA.pl \
  --dir4local_sas_home 'E:/SAS files' \
  --output-prefix SAS_Output_RandID_local_demo \
  --code 'libname saved "~"; data saved.class; set sashelp.class(obs=5); run; proc print data=saved.class; run;'
perl run_sas_codes_or_files_in_ODA.pl \
  --dir4local_sas_home 'E:/SAS files' --dir4listing '~'
perl run_sas_codes_or_files_in_ODA.pl \
  --dir4local_sas_home 'E:/SAS files' --upload-file example.csv
perl run_sas_codes_or_files_in_ODA.pl \
  --dir4local_sas_home 'E:/SAS files' --download-file '~/example.csv' \
  --download-local-path ./example.downloaded.csv
```

When output prefixes differ between persistent runs, specify the same home
explicitly if you want access to previously saved files. The home is supplied
per session request; it is not taken from the environment of the first CLI
that happened to start the persistent server. Changing home preserves WORK.
New session-server code is required; the runtime restarts an older protocol
on first use, so use a new session ID after updating and recreate needed WORK
data. `SAS_ODA_SESSION_PORT` can isolate a separate server (default 8765).

## Local Linux SAS via SASPy STDIO

Use Linux Python with SASPy installed and a licensed, runnable Linux SAS
executable. No Windows Java/IOM/SSPI configuration is needed for STDIO.

```bash
export PIPELINE_PYTHON_BIN="$(command -v python3)"
export SASPY_CFGFILE="$PWD/install/sascfg_linux_local.py"
export SASPY_CFGNAME=linuxlocal
export SASPY_LOCAL_SAS_PATH='/path/to/your/SASFoundation/9.4/sas'
export SASPY_LOCAL_SAS_ENCODING=utf-8
export SAS_ODA_AUTOLOAD_MACROS=0

perl run_sas_codes_or_files_in_ODA.pl --check-saspy-connection-only
perl run_sas_codes_or_files_in_ODA.pl \
  --dir4local_sas_home "$PWD/local_sas_home" \
  --code 'libname saved "~"; data saved.class; set sashelp.class(obs=5); run; proc print data=saved.class; run;' \
  --output-prefix SAS_Output_RandID_linuxlocal \
  --persistent --session-id linux_demo --run-timeout-seconds 120
perl run_sas_codes_or_files_in_ODA.pl \
  --dir4local_sas_home "$PWD/local_sas_home" \
  --dir4listing '~' --persistent --session-id linux_demo
```

Replace the executable path and set encoding to match the installed SAS. The
saved Linux profile uses `saspath` and local STDIO, with no remote hostname or
credentials. An explicit Linux profile fails visibly if connection fails; it
never silently retries the ODA profile.

## Validation and limits

Actual Windows SAS 9.4 tests passed: default home equals the HTML output folder;
text and a permanent two-row SAS dataset were saved through quoted `~` paths;
listing, upload, file information and byte-identical download worked with an
explicit home containing spaces. An exact uploaded test file was deleted and
both other marker files remained. A three-row WORK dataset was reused through
the other runner in the same persistent Windows SAS session.

`tests/test_local_sas_home.pl` checks SAS quoting/comment/inline-data boundaries,
local session setup, invalid/remote path rejection, the Linux STDIO profile,
and both actual session factories with a stub SASPy connection. The factories
receive exactly the requested Linux profile/configuration and retain connection
errors without trying ODA. No local Linux SAS executable was available, so a
live Linux SAS connection has not been verified.

Windows evidence is in the parent development workspace:
`SAS_Output_windows_iom_sspi_20261104/home_live.txt` and `home_delete_one.txt`.