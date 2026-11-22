# Macro discovery and HTML output repair — 22 November 2026

## Cause

The reported `%macroparas(macrorgx=GTEx);proc print;run;` invocation used a
Windows local SAS profile, despite the runner's historical ODA filename. Its
legacy macro searched an unavailable institutional UNC share in its default
`dir=` argument. SAS returned Windows error 67. The saved evidence contained
20 parameter records and an HTML file, but the submission correctly finished
as failed. The failure was not evidence that Firefox was missing.

There were three additional defects in this path:

- Automatic loading still selected the legacy server macro and five helpers;
  the existing portable utility was only exercised by explicit-include tests.
- The portable utility treated the `SASAUTOS` fileref as a literal directory,
  overlooking a configured library inside its concatenated physical paths.
  Calling `SYSGET` for an absent optional environment variable also produced
  an invalid-argument diagnostic.
- Its temporary preview could become the implicit input to a later `PROC PRINT`.
  Separately, the Perl explicit-include debugger accepted only Unix HOME paths,
  discarding Windows drive paths and attempting to write under `H:\home`.

## Changes and compatibility

When neither an explicit definition/include nor a local macro file resolves
`%macroparas`, **both runners now compile the bundled portable utility** into
the current session. The Perl console identifies that choice. This deliberately
changes automatic fallback selection from the policy documented in the
21 November Windows validation report; that report remains a historical record.
Original research macro files are not edited, and an explicitly supplied
definition/include or local macro directory retains precedence.

The portable definition is submitted with the program. Its five obsolete loader
dependencies and their individual remote lookups are unnecessary. Recompilation
replaces an old in-memory definition without restarting the SAS helper or
discarding WORK. Unconfigured, author-specific UNC roots were also removed from
the Perl local discovery list. Explicitly configured network directories remain
available.

The utility expands SASAUTOS filerefs, checks `SYSEXIST` before `SYSGET`, keeps
caller NOTES settings, and points `_LAST_` at the requested result table after
cleaning up its temporary tables. It reads source files; it does **not** execute
the GTEx analysis macros being inspected. Explicit UNC `dir=` requests and
genuine SAS errors are not hidden.

The Perl include debugger now accepts both Windows and Unix absolute HOME paths.
The two compatibility Perl entry points remain byte-identical. The existing
browser-launch policy is unchanged: `--open-html` requests the system's default
browser; `--no-open-html` saves the file without opening it. Firefox is not a
requirement.

SAS documents the [_LAST_ system option](https://support.sas.com/documentation/cdl/en/lesysoptsref/64892/HTML/default/n1jcqq2r7mbk5xn1nsi74aavcdak.htm)
and the [environment-variable functions](https://support.sas.com/documentation/cdl/en/lefunctionsref/63354/HTML/default/p0w6napahk6x0an0z2dzozh2ouzm.htm).

## Reproduction

Full source previews, followed by the parameter table:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --code '%macroparas(macrorgx=GTEx);proc print;run;' \
  --persistent --session-id mc --open-html
```

For a quicker, compact catalog, omit the thousands of source-preview rows:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --code '%macroparas(macrorgx=GTEx,numlines2print=0,print_outdsd=1);' \
  --persistent --session-id mc --open-html

python run_sas_codes_or_files_in_ODA.py \
  --code '%macroparas(macrorgx=GTEx,numlines2print=0,print_outdsd=1);' \
  --persistent --session-id python_catalog --open-html
```

Each runtime owns its own persistent sessions; matching Perl and Python session
names do not share WORK. Library contents depend on the selected SAS host. Use
`dir=` to inspect a specific **SAS-accessible** directory; a client-only path is
not automatically a server-side macro library.

## Regression evidence

The machine-readable [validation record](validation/macroparas-html-20261122.json)
contains final source and artifact hashes, outcomes, timing observations and
installed-copy verification. Private full logs and outputs remain in
`SAS_Output_RandID_macroparas_repair_20261122/`; credentials are not published.

The four live target/runtime combinations are Windows SAS 9.4 with Perl and
Python, and SAS OnDemand with Perl and Python. Checks cover:

1. Compiling a deliberately obsolete macro in an isolated persistent session.
2. Replacing it through ordinary automatic loading, producing the real GTEx
   catalog and saved HTML.
3. Retaining a preexisting WORK sentinel across independent CLI submissions.
4. Ten fixture assertions: exact names via PROC COMPARE, complete signatures,
   caller-table and macro-variable preservation, NOTES preservation, empty-match
   replacement, deduplicated directory lists, configured defaults, SASAUTOS
   fileref discovery and implicit PRINT input selection.

Both local runners returned **20** GTEx definitions; both ODA runners returned
**14**, reflecting the contents of their respective libraries. All 40 SAS
fixture assertions passed. The 75 root Python regression scripts, 93 native
Python tests and 127 focused Perl TAP checks passed. The reusable live harness
was additionally executed with each runner on ODA.

In the installed project, the exact reported program completed successfully in
the existing `mc` session and the default-browser launcher accepted the saved
HTML. A Firefox window titled **SAS Output** was observed; a page screenshot
could not be captured, so no visual-layout verification is claimed. The compact
catalog command completed in **3.90 seconds**, compared with **134.29 seconds**
for that full-source-preview trial. Other tests were active during this work;
these are not controlled benchmark estimates or a general speedup claim. The
original `macroparas.sas` library file's hash is unchanged, and the installed
runtime/test files were individually checked against the repaired sources.

Offline tests additionally verify explicit-source precedence and Windows HOME
acceptance. The full native Python suite includes browser-request tests and
actual MCP transport tests. Live tests do not execute GTEx HTTP requests,
genomic analyses or complete research workflows. Full source previews can take
substantially longer to render than a compact catalog, especially on the local
SAS WORK drive; these are observations on this machine, not portable speed limits.

To repeat the live regression with a configured SAS target, choose a new output
directory and the expected count for that target's actual library:

```bash
python tests/run_live_macroparas_autoload.py --live --language perl \
  --perl /path/to/perl --out RESULTS_PERL --expected-matches 20
python tests/run_live_macroparas_autoload.py --live --language python \
  --out RESULTS_PYTHON --expected-matches 20
```

The harness uses its own sessions and never closes a user's existing `mc`.
