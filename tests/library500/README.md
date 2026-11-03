# Library-derived evaluation batch L001–L500

These are **500 runnable SAS scripts: 50 behavior families with ten different
boundary inputs per family**, rather than 500 unrelated algorithms. The inputs
exercise negative values, zero, numeric missing values, padding, delimiters,
substrings, date boundaries, regular expressions and formats. Expected answers
are calculated in Perl, independently of SAS and the MCP source analyzer.

Each script writes one `LIB500_PASS=Lnnn` marker on success, or an SAS `ERROR:`
assertion on failure. They use DATA _NULL_ and do not create user datasets or
delete local/remote files. PRX cases also assign one temporary session macro
variable. No HTML is expected. A batch shares one persistent SAS session; these
are calculation tests, not 500 independent login tests.

`manifest.json` references 40 original library files and records the source line, source SHA-256,
evidence-line SHA-256, operation, input index, expected answer and normalized
executable-body fingerprint. Source libraries remain unmodified. Function uses
are discovery evidence; these are newly constructed focused evaluations, not
copies of entire original programs or validations of every original macro.
Rebuilding requires the original library; running the checked-in cases does not.

| IDs | Behavior families, in blocks of ten |
| --- | --- |
| L001–L100 | abs, ceil, floor, int, mod, round, sign, sqrt, exp, log |
| L101–L200 | log10, min, max, sum, mean, median, range, n, nmiss, coalesce |
| L201–L300 | lengthn, upcase, lowcase, strip, left, reverse, substr, scan, countw, countc |
| L301–L400 | compress, tranwrd, translate, cats, catx, index, indexc, verify, count, intck |
| L401–L500 | datepart, year, weekday, prxmatch, prxchange, missing, input, put, repeat, trim |

From the MCP4SAS root in Cygwin:

```bash
export PATH=/usr/bin:$PATH
perl tools/build_library500_evaluations.pl /cygdrive/h/F_Queens/360yunpan/SASCodesLibrary
prove tests/test_library500_evaluations.pl tests/test_include_source_order.pl
perl tests/run_live_library500.pl --live
```

For an isolated rerun:

```bash
perl tests/run_live_library500.pl --live --only L431,L441 --batch-size 1
OPEN_RESULT=0 SAS_ODA_AUTOLOAD_MACROS=0 \
  perl run_sas_codes_or_files_in_ODA.pl --file tests/library500/L431.sas \
  --run-timeout-seconds 180 --output-prefix SAS_Output_L431
```

The live harness requires configured SAS ODA credentials, submits at most 100
cases per job, and preserves SAS programs, CLI logs, SAS logs and `results.json`
in a unique ignored `SAS_Output_library500_live_*` directory. Success requires
exit zero, no SAS ERROR lines, and exactly one anchored result marker per case;
echoed SAS source is insufficient. A failed batch marks its cases unverified,
even if some individual markers appear; use `--batch-size 1` to isolate them.

On **2026-11-02**, all **500/500** cases passed live in five 100-case batches.
`verified_results_2026-11-02.json` preserves the per-case results. See
`../../RealExamples4ImprovingMCP4SAS.md` for failed attempts, fixes and commands.
