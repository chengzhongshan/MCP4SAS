# GTEx macro catalog and macroparas regression

15 November 2026. The requested `%macroparas(macrorgx=GTex);` was executed in actual SAS. The installed Windows library contains **20 matched macro definitions**; SAS ODA contains **14**. The difference is library content/version, not a case-sensitive search failure. No GTEx API analysis, new scientific result or complete genomic pipeline was executed by inspecting these signatures.

GTEx supplies gene-expression and genetic-association resources across tissues. An eQTL associates genetic variation with expression; an sQTL concerns splicing. The catalog below describes what the inspected programs attempt to do, not evidence that every analysis is scientifically validated.

## Matched macros

| Macro | Purpose | ODA match |
|---|---|---|
| `Boxplots4GenesInGTExV8` | Expression boxplots for selected genes across tissues, optionally split by sex. | Yes |
| `Boxplots4GenesInGTExV8ByAA` | Expression boxplots using the supplied AA/EA grouping. | Yes |
| `Boxplots4GenesInGTExV8ByGrps` | Expression boxplots stratified by one or several supplied grouping variables. | Yes |
| `CaculateMulteQTLs_in_GTEx` | Collect several SNP associations for one gene; optional genotype collection, boxplots, heatmaps and GLM. | Yes |
| `Caculate_eQTL_in_GTEx` | Older single-SNP/single-gene genotype-expression workflow. | Yes |
| `GTEX_SexBasedDiffGeneHeatmap` | Read precomputed sex-associated expression results, attach gene annotations and draw a heatmap. | Yes |
| `GTEx_Hap_eQTL_Analyzer` | Haplotype-oriented expression analysis with a supplied LD-pruned SNP list and PCA-related controls. | Yes |
| `GTEx_Sex_Biased_eQTL_Analyzer` | Sex-stratified extension of the haplotype/eQTL workflow. | No |
| `GTEx_eQTL_and_sbExp_Analysis` | Combine a variant-centered eQTL query with a precomputed sex-associated expression file. | No |
| `GTEx_eQTL_genes_scatterplot` | Assemble gene eQTL results with a supplied hg38 GTF table for regional/scatter visualization. | Yes |
| `GetMultQTLs4GenesInGTEx` | Extend the SNP-query workflow to multiple genes and combine expression/association outputs. | Yes |
| `GetSexBiasedGenes4SNP_in_GTEx` | Attempt to link query genotypes with expression of sex-associated genes within a tissue. | No |
| `Haplotype_Analysis4SNPs_in_GTEx` | Genotype/expression and haplotype workflow for a specified SNP set and gene. | Yes |
| `QueryGTEx4GeneID` | Look up gene reference records from supplied gene identifiers/symbols. | Yes |
| `QueryGTExeQTLs4Genesymbol` | Gene-oriented association lookup and aggregation wrapper. | Yes |
| `QueryGTExeQTLs4MultEnsemblGenes` | Loop over several Ensembl gene IDs and combine association results. | Yes |
| `Query_GTEx_SNP_by_rsid` | Retrieve variant reference information from a query identifier. | No |
| `Query_GTEx_eQTLs4Genesymbol` | Request a gene association table using a versioned Ensembl ID and dataset selector. | Yes |
| `Query_GTEx_eQTLs4SNP` | Variant-centered eQTL association lookup. | No |
| `Query_GTEx_sQTLs4SNP` | Variant-centered splicing-QTL association lookup. | No |

Full signatures, key parameters, individual cautions and SHA256 source hashes are in [the CSV catalog](macros/gtex_macro_catalog_20261115.csv). Local hashes describe the inspected H: files, not the possibly different ODA source files.

## Which macros to start with

* Gene expression: start with `Boxplots4GenesInGTExV8` and a documented prepared expression table. Add `ByGrps` when sample grouping annotations are available.
* Gene/variant lookup: distinguish `QueryGTEx4GeneID`, `QueryGTExeQTLs4Genesymbol` and `Query_GTEx_eQTLs4Genesymbol`. They are separate interfaces; the last currently accepts a versioned Ensembl ID, not an arbitrary gene symbol.
* Multiple associations: use the parameter-rich `CaculateMulteQTLs_in_GTEx` and `GetMultQTLs4GenesInGTEx` as starting points after validating their API/data inputs. The older `Caculate_eQTL_in_GTEx` explicitly recommends its multi-SNP replacement.
* Regional graphics: `GTEx_eQTL_genes_scatterplot` needs a compatible hg38 GTF table and coordinate interval.
* Haplotype/sex-related workflows: treat these as advanced research code. `GTEx_Sex_Biased_eQTL_Analyzer` is marked under development. `GetSexBiasedGenes4SNP_in_GTEx` warns about changing numeric sample IDs across requests; identity matching and sex inference need independent validation.

The optional GLM in `CaculateMulteQTLs_in_GTEx` does not include the full GTEx covariate set, as its own source warns. Do not present its P values as reproductions of published GTEx statistics. API availability, pagination, scientific models and all research outputs remain outside this catalog test.

## Bugs found and repaired

The original local utility found 20 matches but returned failure because its default directory list probed an unavailable institution-specific UNC path (Windows error 67). That is a real filesystem failure; the runner diagnostic was not suppressed. The replacement scans a configured directory, the configured SAS autocall library, or HOME/Macros. Automatic discovery does not probe arbitrary personal network shares.

The portable repair in [macroparas_portable.sas](../examples/sas_macros/macroparas_portable.sas) also:

* Uses a local macro-variable scope and unique temporary table names; it does not delete caller `_mparas*`, `_macros_` or `macroparas*` datasets.
* Returns an empty table for zero matches, replacing a previous result without an invalid SQL INTO range or session-wide ABORT.
* Enumerates files with SAS directory functions, without a shell or PROC PRINTTO redirection. Directories need not be named Macros.
* Matches filenames case-insensitively, handles spaces/quoted directory lists, and deduplicates repeated paths.
* Removes comments and respects balanced parentheses and quoted strings when extracting the primary declaration. Parsing continues past the source-preview limit. Bare zero-argument declarations are supported.
* Releases filerefs and directory handles and leaves NOTES/title settings unchanged.

Output preserves the existing `macro` and `macro_paras` columns and adds `path`. The legacy `verbose` and `IsSASOnDemand` keywords remain accepted; directory access now uses the same SAS implementation on both platforms. This is a source-inspection utility, not a complete parser for every possible macro-quoting construction. Unusual unmatched quotation/parenthesis escapes need the original source review.

An ODA catalog export also exposed an upload-size verification failure before user code was submitted. The shared transfer helper now discards stale pre-transfer metadata and permits one verified retry from a private copy. Persistent mismatches still fail with expected/observed sizes. The original transient mismatch cause was not conclusively established. The retry never replays user SAS code. Three regression tests cover stale metadata, a successful bounded retry, and failure after the second mismatch.

## Run the repaired utility

The local H: `macroparas.sas` was backed up and replaced with the tested repair. Its Windows default remains that existing H: library; non-Windows SAS defaults to HOME/Macros. A fresh MCP call to the installed utility subsequently returned 20 matches with exit 0 and no SAS warnings or data-quality diagnostics. The 20 GTEx analysis source files were not changed. The original backup and installed hashes are recorded in the local execution evidence. No old ODA research macro was overwritten; the repaired utility was included explicitly for its ODA tests.

For a portable setup, load the repaired source and name the library once:

```sas
%include "examples/sas_macros/macroparas_portable.sas";
%let MCP4SAS_MACRO_DIR=/path/to/your/Macros;
%macroparas(macrorgx=GTex);

/* For a compact result suitable for an AI agent or a quick review: */
%macroparas(macrorgx=GTex,numlines2print=0,print_outdsd=1);
```

The default 10,000-line source preview is retained for compatibility and can produce a large HTML result. Setting `numlines2print=0` avoids printing entire source files; it does not truncate declaration extraction. A specific `dir=` takes precedence over the configured default. A macro variable or environment variable named `MCP4SAS_MACRO_DIR` configures the generic replacement.

## Reusable tests and evidence

```bash
python tests/test_macroparas_gtex.py
perl tests/test_macroparas_gtex.pl

# Actual SAS execution, both runners:
python tests/test_macroparas_gtex.py --live --runner both --perl /path/to/perl --saspy-cfgname oda --saspy-cfgfile /path/to/sascfg_personal.py
```

Offline invocation checks the source/dependency plan and clearly says that live SAS tests were not run. `tests/macroparas_gtex_regression.sas` creates only isolated WORK fixtures. It does not contact the GTEx API or run any inspected macro body. Each live run checks:

1. PROC COMPARE agrees with the independently specified expected macro names.
2. A complete commented/nested/quoted declaration is extracted beyond the preview limit.
3. Caller tables survive.
4. Caller macro variables survive.
5. NOTES remains unchanged.
6. A zero-match call clears stale results.
7. Quoted duplicate directories yield no duplicate definitions.
8. A configured default directory works without a dir argument.

**All eight checks passed through both Perl and Python on both ODA and local Windows COM: 32 checks, four actual executions, no SAS errors, warnings or data-quality diagnostics.** Windows COM tests are one-shot because its workspace is bound to the creating thread; the initial rejected persistent request submitted no SAS code. The plugin target-selection guard also correctly rejected an ODA request while Windows COM was selected; ODA tests used explicit CLI profiles without changing the selected VS Code target.

Initial failed attempts are retained: the original UNC error, a regression-test assertion syntax error corrected before the successful runs, the quoted-directory concatenation bug corrected in the utility, and the upload-verification failure. The first local default-directory customization also returned zero matches; it was corrected and the installed bare call was checked again. These initial failures are not counted as successful executions.

Full code, stdout/stderr, SAS logs, HTML, catalog CSVs and execution JSON are retained locally under `SAS_Output_macroparas_gtex/`. The tracked [validation manifest](validation/macroparas-gtex-20261115.json) records source hashes and actual outcomes.
