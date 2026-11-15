# Additional library and online-sample workflows

The two frozen collections each contain 500 cases: 25 workflow families with 20
different deterministic input datasets or parameter settings. They supplement
the earlier 4,550-case catalog. Fixture values are invented regression data,
not published research findings. Each numerical output cell has an independently
calculated oracle in `manifest.json`; no expected constants are embedded in the
submitted SAS code. Metadata-selection cases also check retained column names.

- `library_workflows500/`: actual definitions from 25 author macro files,
  namespaced to protect the original files. Three corrections to the ZIP-reader
  test copies are explicitly recorded as before/after replacements in the
  manifest; the H: originals are unchanged.
- `online_samples500/`: samples from four local book listings, including the
  meta-analysis file requested by the author. Five original macro definitions
  are extracted from that listing. Adaptations and derived extensions have
  source anchors, original hashes, and scope labels.

Run from the repository root using Python 3.10 or later with SASPy
and a configured SAS target. Perl execution also needs the installed Perl
runtime. This Python file is a **maintainer driver** that can select either
public CLI; the Python product runner does not launch Perl.

```bash
python tests/audit_new_workflows.py
python tests/test_new_workflow_evaluator.py
python tests/run_new_workflows.py --live --collection online_samples500 \
  --runtime python --batch-size 25 --out SAS_Output_samples_python
python tests/run_new_workflows.py --live --collection online_samples500 \
  --runtime perl --perl /usr/bin/perl --batch-size 25 --out SAS_Output_samples_perl
```

For Windows, supply the installed Cygwin `perl.exe` to `--perl`. Substitute
`library_workflows500` for the other collection. `--pilot` selects the first
case from each family; `--only V6201,V6341,V6421` selects exact IDs. Supply
`--saspy-cfgname` and `--saspy-cfgfile` to test another configured target.
Output directories must be new. The default SAS ODA profile is `oda`.

The driver validates frozen program hashes, relocates input aliases, creates a
unique per-run remote namespace, discovers and uploads macro dependencies, and
preserves source snapshots, submitted programs, CLI logs, SAS logs, terminal
status, CSVs, and SVGs. Downloads and cleanup are separate operations. Cleanup
deletes only explicitly owned files; it does not traverse user directories.
Case counts and SAS submission counts are reported separately. A failed batch
is retained and must be rerun to obtain passing evidence.

```bash
python tests/audit_new_workflow_results.py \
  SAS_Output_samples_python SAS_Output_samples_perl
```

The results auditor expects complete 500-case selections. It rereads all
numerical CSVs and actual runtime completion markers, checks execution status,
parses SVGs, and hashes the artifacts. It does not certify visual publication
quality or the scientific suitability of every legacy statistical formula.

The original source directories are needed only to regenerate or independently
rehash the originals. The frozen fixtures and per-run alias relocation allow
execution from another checkout without an H: drive:

```bash
python tests/build_library_workflows500.py
python tests/build_online_samples500.py
```

Source book attribution and formula limitations are documented in the manifests
and [execution report](../docs/NEW_LIBRARY_AND_SAMPLE_TEST_REPORT.md). Do not
silently edit a frozen program or its oracle to turn a failed result into a pass.
