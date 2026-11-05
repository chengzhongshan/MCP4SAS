# GTEx boxplots after an abruptly terminated SAS ODA session

The saved `SAS_Output_RandID979354/output.html.info.txt` contains the exact
MAP3K19/R3HDM1 request with `UseGeneratedDsd=0`. Its terminal status records
`sas_oda_remote_session_termination`, exit 74, and no definitive SAS runtime log.
The macro bootstrap completed. A resource failure is plausible, but the log
does not prove whether disk, memory, a service limit or another cause ended SAS.
The failed large job was not resubmitted.

## Why the original macro takes the expensive path

The original macro in the user's library:

- Treats `UseGeneratedDsd=0` as a request to build the dataset. `PreviousDsd=tgt`
  is only used for cached plotting when `UseGeneratedDsd=1`.
- Checks for `GTEx.exp_all`; if it is absent, invokes the UCSC importer on
  `https://cells.ucsc.edu/gtex8/exprMatrix.tsv.gz`.
- Imports the whole matrix before selecting the two genes. The importer defaults
  to up to one million selected columns and an extremely large record length.
  Putting the file in WORK does not remove all resource limits.
- Uses an outer condition that can rebuild from `exp_all` even when cached
  plotting was requested, modifies the selected previous dataset in place, and
  contains `%sysfunc(exists(...))` where SAS's dataset function is `exist`.

A LIBNAME assignment made in SAS Studio is not automatically an assignment in a
new SASPy/ODA connection. Explicitly assign `GTEx` to the folder containing the
prepared table in the same submission. Do not assume an old Studio libref exists.

## Cache-only alternative

`examples/sas_macros/Boxplots4GenesInGTExV8_Cached.sas` defines
`%Boxplots4GenesInGTExV8_Cached` without modifying the user's original local or
online macro. It requires a prepared long table with:

- `rownames`: gene symbol, or an identifier ending in `|SYMBOL`;
- numeric `exp`: expression already transformed as intended for plotting;
- `cluster`; and
- `sex` for `bysex=1`, or `Tissue` otherwise.

It filters the requested genes, checks each is present after optional WHERE
filtering, writes a separate output table and draws the panels. It preserves the
expression scale and the cache. Missing input, invalid columns and requests with
`UseGeneratedDsd=0` fail with an actionable error. There is no HTTP or full-matrix
download path. Existing outputs require explicit `replace=1`, and the output
member name must differ from the source cache member.

From the MCP4SAS checkout in Cygwin, set the real prepared-data folder below:

```bash
{
  cat examples/sas_macros/Boxplots4GenesInGTExV8_Cached.sas
  cat <<'SAS'
libname GTEx '/home/YOUR_ACCOUNT/PREPARED_DATA_FOLDER';
%Boxplots4GenesInGTExV8_Cached(
  genes=MAP3K19 R3HDM1,
  dsdout=exp,
  bysex=1,
  UseGeneratedDsd=1,
  PreviousDsd=tgt,
  Lib4PreviousDsd=GTEx,
  WhereFilters4Boxplot=%str(),
  boxplot_width=1200,
  boxplot_height=1000
);
SAS
} | perl run_sas_codes_or_files_in_ODA.pl --code -
```

## If a prepared cache is unavailable

Prepare a gene subset on the local computer before importing into SAS. The Perl
utility streams an existing local UCSC-style tab-delimited matrix or gzip file
and retains its sample header and every matching gene row:

```bash
perl tools/subset_gtex_expression.pl \
  --input /path/to/exprMatrix.tsv.gz \
  --genes 'MAP3K19 R3HDM1' \
  --output gtex_two_genes.tsv
```

It never overwrites the input or an existing output. Missing genes, ragged selected
rows and corrupt/truncated gzip files fail before the output is published. Only
one matrix row is held at a time. This utility does not download the full file
or construct sex/cluster metadata. Import the small subset and join matching
sample annotations to create the long cache before calling the cache-only plot.
It deliberately does not guess missing phenotype information.

For the original macro, a minimal repair is to prioritize `UseGeneratedDsd=1`,
validate the prepared dataset before starting work, replace `exists` with `exist`,
filter into a separate WORK table, and require explicit opt-in before any full
matrix download. Increasing MCP's timeout alone does not bound matrix resource
use or recover an abruptly terminated SAS session.

## Verification

`tests/test_gtex_expression_subset.pl` passed 12 offline assertions for plain/gzip
input, exact expression preservation, missing genes, existing output, ragged rows
and truncation. `tests/test_live_gtex_cache_only.pl --live` passed three isolated
SAS ODA cases: a 24-row synthetic source produced the correct 16-row two-gene
output while preserving the source, missing-cache refusal, and rebuild refusal.
The passing live run is retained in the ignored `SAS_Output_gtex_cache_*` folder
named by `SAS_Output_resume_20261103/gtex_live.tap`.

Development exposed a FINDW detail: its `T` modifier trims the delimiter argument
as well as the search strings, so a space-only delimiter becomes empty. The final
macro strips the gene token and uses only `I` for case-insensitive matching. See
the [SAS FINDW documentation](https://support.sas.com/documentation/cdl/en/lefunctionsref/63354/HTML/default/p16rdsa30vmm43n1ej4936nwa01t.htm).
Earlier failed prototypes remain local for diagnosis and are not counted as
passing evidence. No large expression matrix or original user dataset was used
in these tests.
