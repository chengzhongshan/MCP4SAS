# Prompts for the supplied MCP4SAS examples

Tell the agent the absolute path to your MCP4SAS checkout. These prompts run
saved programs through the configured MCP tool; they do not ask the agent to
recreate the plotting macros. Use one named persistent session for submission
and collection. Upload the case's manifest inputs, read the POC_OUT path from
the actual SAS log, download every listed output, and run the Perl checker.
Preserve warnings and report failures rather than inventing a result.

## First SAS result

> Run the `hello` example in `examples/poc/manifest.json` through MCP4SAS. Execute
> the supplied SAS file, collect hello.csv from its POC_OUT directory, run the
> supplied output checker and show the first five teaching records and the log
> path. Explain what the DATA step, PRINT and EXPORT procedures do.

## Clustergram

> Run the supplied `clustergram` case through MCP4SAS, including its listed
> input upload and output collection. Use the existing clustergram4sas and
> review_tree_branches definitions in the saved program. Check the 40-gene,
> ten-tissue matrix and within-gene transformation with the supplied checker.
> Show the clustergram and branch review and explain relative versus absolute
> expression. Keep all warnings in the report.

## Regional association and transcript models

> Run `gene_gtf` through MCP4SAS using its supplied program and inputs. Collect
> the figure, numerical tables and log. Check the 43 selected associations,
> GRCh37 interval and three transcript identifiers. Explain the P-value axis
> and transcript tracks, and why nearby genes are not automatically causal.

## Mutation oncoprint

> Run the supplied `oncoprint` case through MCP4SAS. Upload the listed template,
> execute the existing MGXOncoPrint caller and collect all listed outputs.
> Run the checker and show the figure and log. Explain that the 64 events and
> groups are synthetic, with 96 possible pairs and 94 assessable pairs.
> Distinguish an unassessable pair from a pair with no observed variant.

## Forest plots

> Run `forest` through MCP4SAS and collect both female and male panels, their
> numerical tables and the native SVG files. Check the six selected effects
> with the supplied checker. Explain the OR=1 reference and approximate SE
> reconstruction from rounded confidence limits. Do not call the contrast a
> proven sex interaction merely because the plotted estimates differ.

## Three-panel regional GWAS plot

> Run the supplied `multi_gwas_gtf` program through MCP4SAS. It uses 1,880
> prepared variants, three GWAS panels and GRCh37 gene/exon annotations. Keep
> each P-value column paired with its corresponding signed statistic. Collect
> the figure, template and all numerical tables, and run the output checker.
> Report the displayed top-to-bottom order and distinguish missing numeric LD
> from the macro's display fallback. Preserve the supplied SNP-label headroom
> parameters and explain the scientific limits described in the appendix.

No model-token, cost or authoring-success measurements are attached to these
prompts. The PoC's retained comparisons executed saved programs.
