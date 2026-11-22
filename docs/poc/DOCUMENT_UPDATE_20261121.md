# Author document update

The homepage now presents the author's 20 November 2026 revisions:

- `MCP4SAS_Proof_of_Concept_Nove_20_2026.docx`
- `MCP4SAS_Use_Case_Appendix_Nov_20_2026.docx`

The files retain their supplied names and original bytes. The [document source
record](document-sources.json) contains SHA-256 hashes, reader-copy hashes,
paragraph/table counts and embedded-image hashes. `examples/poc/manifest.json`
now identifies these two current source documents. Older Word files remain
available at their existing paths for compatibility with previously shared links.

The GitHub reader versions transcribe the updated wording, tables, captions
and SAS excerpt; their changes are limited to Markdown formatting, navigation,
source-code links and the explicitly separated assembly note. No runtime
measurements were substituted for the author's retained comparison values.

All five appendix PNGs are byte-identical to the previously published figures.
The proof-of-concept workflow diagram differs and has been replaced with the
image embedded in the new Word file. The equal-height homepage composition
uses only the unchanged appendix figures, so it remains unchanged.

## Assembly provenance discrepancy

The new appendix describes the regional transcript example and the multi-GWAS
annotation as **GRCh38**. Existing source records identify **GRCh37**:

- The frozen `examples/poc/programs/gene_gtf.sas` labels its selected
  annotation “Real GRCh37 annotation” near its data-loading code.
- The pre-existing example provenance identifies GENCODE v49lift37 coordinates
  on GRCh37.
- The earlier appendix described both regional examples as GRCh37.

This is a documentation/source conflict, not evidence that a coordinate
conversion was performed. The updated Word files and their scientific wording
are preserved. No coordinates, input tables, macro definitions or validated
programs were changed merely to match the new labels. Before reusing either
regional example in a scientific analysis, reconcile the GWAS and annotation
source assemblies against their original data headers/release records. Do not
mix assemblies or treat successful numerical/output comparisons as proof that
the assembly labels are correct.

## Verification

Document integrity tests check the published originals against their source
hashes, verify every embedded image, and confirm that all nonempty source
paragraphs and table cells appear in the reader copies. Existing PoC package
tests check the frozen SAS programs and inputs. The homepage layout test
continues to require three equal-height previews without cropping or stretching.

Local results: all 212 existing PoC package assertions passed; both document
integrity/transcription tests and the homepage composition test passed. The
frozen case definitions, program/input hashes, runtime provenance and evidence
scope are unchanged. All six extracted images were inspected; the five plot
images retain their prior hashes.

The supplied Word files were not re-typeset. Fresh page rendering could not be
completed here: the document renderer found no installed LibreOffice, and the
read-only Word export stalled. Its test-owned hidden process was stopped.
This update therefore makes no claim of a new Word pagination/layout review.

This update republishes author documents; it is not a new execution benchmark
or full scientific validation. Retained runtime/output checks remain separately
documented in the linked execution reports.
