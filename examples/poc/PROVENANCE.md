# Source and evidence provenance

The source documents are the author's
`MCP4SAS_Proof_of_Concept_Scientifically_Edited.docx` and
`MCP4SAS_Use_Case_Appendix_Scientifically_Edited.docx`, supplied on 13 November
2026. Their evaluation date remains 12 November 2026. Unchanged copies are in
[docs/poc](../../docs/poc/README.md); their SHA-256 hashes are recorded in
[manifest.json](manifest.json). Reader Markdown is a transcription with links
and code-block formatting. All six embedded PNGs were extracted without
redrawing or changing their values.

## Scientific programs

The five programs are byte-identical copies of the retained PoC payloads.
Required macro definitions are included in those payloads. The `hello` program
and the Perl execution/validation helpers are additional teaching materials.

The underlying book companion preserves source-derived macro definitions from
COVID19_GWAS_Analyzer at `4fa6fa710b8506b4aa410c0dfed304d447e41c8a` and
MultiGWAS-Explorer at `ab5413c5fa1a05b94be3dea5a9e2919c513fd884`, with book-owned
display callers and the MGXOncoPrint macro. The frozen payload hashes identify
the actual versions used here; they should not be inferred from either
repository's current main branch. Original source comments and attributions
remain in the programs.

The regional transcript inputs retain GENCODE v49lift37 coordinates on GRCh37.
The expression input is the retained GTEx v8 tissue-median panel. PGC examples
use selected prepared summary statistics and annotations. The oncoprint's
events, clinical group assignments and assessable states are synthetic. These
fixtures are not patient-level observations or a new association analysis.
The source projects' and data providers' original terms and attribution apply;
this showcase does not grant a new license over third-party material.

## Retained comparisons

MCP4SAS runtime revision:
`fdc6d0f1fcd840d6a87174a5ec6ce36c89e5fa82`.

- Four-case comparison: direct trial 2 versus MCP trial 11; 72 checks passed,
  including seven decoded PNG arrays with identical pixels.
- Additional multi-GWAS comparison: direct trial 14 versus MCP trial 15;
  19 numerical/rendering checks passed.
- Original output tables and logs remain in the author's retained evaluation
  archive. Public runtime summaries are also available in
  [the performance record](../../docs/performance/2026-11-12/measurements.json).

The 149.49-second optimized MCP workflow and 164.27-second direct baseline were
single observations at different times with different transfer implementations.
The per-submission measurements in the edited PoC remain distinct from these
whole-workflow times. Agent writing/debugging, model tokens, billed cost and
human effort were not measured. Scientific and appearance checks have separate
roles; successful execution does not establish biological validity.

## Package checks

The new Perl checker was run against retained outputs for all five scientific
cases. It independently checks selected transformations, effect reconstruction,
callability denominators and signed LD arithmetic, alongside file/row checks.
New executions of the packaged helper are recorded separately in
[SHOWCASE_VALIDATION.md](../../docs/poc/SHOWCASE_VALIDATION.md). They must not be
described as fresh paired speed or autonomous-agent benchmarks.
