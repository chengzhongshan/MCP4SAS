# Running the Python runner from Cygwin

The Python runner can start from Cygwin and use a configured native Windows
Python with SASPy. It does not require the launching Cygwin interpreter to have
SASPy installed as well.

An overly strict platform check previously rejected this combination:
`cygwin` in the launcher and `win32` in the selected Python. The corrected check
accepts that specific transition after verifying Python 3.10+ and SASPy. Other
platform mismatches, missing SASPy and invalid explicitly configured
interpreters remain errors; no unrelated environment is silently substituted.

Before starting native Python, the runner converts its own launcher path,
client-side file/output/configuration arguments and relevant client environment
paths. SAS program text, remote listings, remote download sources and other
server-side paths remain unchanged. Native dependency discovery also recognizes
client drive mounts such as `/cygdrive/c/project/input.tsv` inside SAS source.
The handoff occurs before SAS submission and never retries a submitted job.

The regression is `tests/test_cygwin_python_handoff.py`. Its ordinary checks run
without SAS. The optional Windows test launches an actual Cygwin Python, hands
off to native Python with SASPy, and intercepts execution before any SAS
connection. It checks inline code, filenames, spaces, configuration paths and
unchanged remote paths. Eight checks passed. A separate live trial then started
from the installed project's recorded Cygwin environment, handed off to native
Windows Python and submitted the reported GTEx program to local Windows SAS.
It returned 20 matches and saved HTML with exit 0. The owned test session was
closed; existing user sessions were preserved. This does not claim that the
new interpreter handoff was tested with every possible SAS connection profile.

The [validation record](validation/macroparas-source-viewer-20261122.json)
contains source hashes, installed-copy verification and execution outcomes.

An existing installation without the fix can temporarily launch a known native
Python explicitly. For the tested interpreter on this computer, from the
MCP4SAS project folder in Cygwin:

```bash
PIPELINE_PYTHON_BIN='C:/Users/cheng/anaconda3/python.exe' \
  /cygdrive/c/Users/cheng/anaconda3/python.exe ./run_sas_codes_or_files_in_ODA.py \
  --code '%macroparas(macrorgx=GTEx,numlines2print=1000,print_outdsd=1);' \
  --persistent --session-id mc --open-html
```

This changes the interpreter setting for that command only. It does not change
the selected SAS profile. On another computer, use that installation's actual
native Python path, rather than copying this user's path.
