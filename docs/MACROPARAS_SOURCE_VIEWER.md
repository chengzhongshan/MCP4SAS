# Query and copy SAS macros with macroparas

`%macroparas` finds macro source files in the selected library and displays their
definitions and demonstrations. Matching is case-insensitive. Inspecting a macro
does not execute it or run its demo.

## Read and copy a macro

From the MCP4SAS project folder:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --code '%macroparas(macrorgx=GTEx);' \
  --persistent --session-id mc --open-html

python run_sas_codes_or_files_in_ODA.py \
  --code '%macroparas(macrorgx=GTEx);' \
  --persistent --session-id python_catalog --open-html
```

Each macro has one full-path heading, followed by a single source column in
bold dark-blue Arial on the original light-blue background. The report and
headings are left-aligned. There are no line numbers, observation numbers or
repeated path columns in the source body. Select the source below its heading,
including the demo at the end, and copy it into a SAS program.

The macro already produces HTML. A trailing `PROC PRINT;` is unnecessary: it
prints an additional parameter dataset using SAS's default layout. For a compact
parameter-only catalog, use:

```sas
%macroparas(macrorgx=GTEx,numlines2print=0,print_outdsd=1);
```

The optional summary displays macro names and parameters. The source path remains
in the output dataset for programmatic use. `numlines2print=` limits preview
lines **per file**; the default is 10,000. Signature extraction continues beyond
that preview limit. The source viewer follows the original macro's left-aligned
text presentation; it is not a byte-for-byte source-file export.

## Included in the automatically transferred loader

The maintained portable implementation is embedded in
`MCPDeps/importallmacros_ue.sas`. It is self-contained: no second SAS include or
remote request is needed to define `%macroparas`. For example:

```bash
./run_sas_codes_or_files_in_ODA.pl \
  --code '%include "MCPDeps/importallmacros_ue.sas"; %macroparas(macrorgx=GTEx);' \
  --persistent --session-id mc --open-html
```

Both runners detect the local include and upload it to the selected SAS HOME
working directory before submitting the rewritten include. An explicit
`%importallmacros_ue(...)` call also resolves the bundled loader when the user has
not supplied their own local version. The native Python runner now stages this
same helper in the existing transfer manifest when global macro autoload is
explicitly enabled. The Perl global-bootstrap path already transfers it.

Including the file defines the loader and the query utility. Calling
`%importallmacros_ue` loads the library; it also remembers `MacroDir=` as the
default directory for subsequent queries. `dir=` on an individual query takes
precedence:

```sas
%importallmacros_ue(MacroDir=/your/SAS/accessible/Macros,fileRgx=GTEx);
%macroparas(macrorgx=GTEx);
%macroparas(macrorgx=Beta,dir=/another/SAS/accessible/Macros);
```

Bulk import skips legacy `macroparas.sas` and `macroparas_portable.sas` files so
they cannot overwrite the bundled query utility. Users can still explicitly
include a custom definition afterward. Original research-library files are not
edited. Simple programs and targeted queries retain the targeted loading path;
the update does not enable a full-library import for every submission.

## Maintenance and tests

Edit `examples/sas_macros/macroparas_portable.sas`, then regenerate its embedded
copy:

```bash
python tools/sync_macroparas_bundle.py
python tools/sync_macroparas_bundle.py --check
python tests/test_macroparas_html.py
```

The HTML regression uses two macros with demos, quotes, angle brackets,
ampersands, repeated statements and blank lines. It extracts actual HTML cell
text **without removing line numbers or repairing spaces**, submits that copied
code to SAS, and checks the resulting values. Ordinary spaces are preserved
inside code and quoted values. Blank source lines use a tab-only display cell
to prevent ODS from inserting an unprintable nonbreaking space.

Live checks cover both runners on Windows SAS and SAS OnDemand, with scoped
sessions. The importer test selects only the query-utility filenames; it does
not rerun the full research macro collection. The original and revised viewer
were also compared using the actual `QueryGTEx4GeneID.sas` source. No GTEx query
or biological analysis was executed by those source-inspection checks.
