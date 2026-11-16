# Beta macro repair and executable regression

15 November 2026. `%macroparas(macrorgx=Beta);` found three local macros:
`Beta2OR_forest_plot`, `estimate_alpha_beta`, and `scASE_betabino`. The search
completed successfully. Some signatures appeared on the line after the
`MACROPARAS_BETA_SIGNATURE=` label because SAS wrapped long PUT values; they
were not empty dataset values.

## Confirmed scASE defects

The original source omitted the comma after `tot_var=tot`. Consequently,
`outdsd=` was not a separate declared keyword. An actual local Windows SAS run
of the original file reproduced:

```text
ERROR: The keyword parameter OUTDSD was not defined with the macro.
```

The body also used `model_vars` and `modelvars` instead of `model_var`, hard-coded
the predictor `x` in NLMIXED, and wrote a fixed parameter-estimate table instead
of the requested `outdsd`. These are interface/wiring defects, not a reason to
change the scientific question or substitute another model.

The repair is [examples/sas_macros/scASE_betabino.sas](../examples/sas_macros/scASE_betabino.sas).
It retains the FMM initializer, original beta-binomial log likelihood,
rho/phi transformation and normal subject random intercept. It corrects the
parameter separator, predictor names and requested output routing. The random
intercept variance is constrained to its valid nonnegative domain. Initializer
and mixed-model convergence are checked explicitly.

Additional checks reject missing datasets/variables, nonnumeric count/predictor
fields, incomplete or invalid counts, and conflicting output names. Requested
outputs must differ from the input. After valid output-name validation, failed
input checks leave empty estimates/predictions and a non-success status instead
of a previous fit's estimates. Output/input alias rejection preserves the input.
Temporary datasets and initializer macro variables are scoped to the call.

## Input and outputs

Each row contains a counted outcome out of a positive integer total, one numeric
predictor and a subject identifier. The macro fits one numeric predictor; it
does not implement a CLASS statement or a general multiple-covariate formula.
Repeated observations identify each subject's cluster.

```sas
%include "examples/sas_macros/scASE_betabino.sas";
%scASE_betabino(
    dsdin=work.counts,
    model_var=exposure,
    subj_var=donor_id,
    read_var=alternate_reads,
    tot_var=total_reads,
    outdsd=work.fit_parameters,
    predout=work.fit_predictions,
    statusout=work.fit_status
);
```

`outdsd` now receives the NLMIXED parameter estimates. The optional `predout`
defaults to the former fixed name `prob_vals`; `statusout` optionally preserves
the convergence table. Inspect the SAS log and `Status=0` before interpreting a
fit. Status 999 denotes that fitting was not completed after input validation.
The complete runnable data generator is in the test file below; `work.counts`
in this interface example is a placeholder for the reader's prepared table.

The corrected source was installed in the author's local H: macro library after
backing up its original bytes. `Beta2OR_forest_plot` and `estimate_alpha_beta`
were not modified or executed as analyses in this task.

## Runner bug uncovered by the tests

The negative-case program includes another SAS file, which includes the repaired
macro. Python uploaded and rewrote both levels. The Perl runner uploaded the
parent alone, leaving the child's client-relative path inaccessible to SAS ODA.
This produced a genuine `Cannot open %INCLUDE file` failure instead of the
intended count-validation error.

The Perl dependency planner now traverses static local include chains, resolves
children relative to their parent, and rewrites private copies to the actual SAS
HOME destinations. It transfers the graph in one bulk request and preserves the
original local files and repeated source statements. It also handles a single
file-relative include outside the current directory. Cycles and conflicting
basenames are rejected before uploading. Runtime-resolved and server-only
includes remain for SAS to resolve. Definitions supplied by explicit includes
are not speculatively loaded again before their source statement.

This repair concerns static quoted file includes. It does not claim to resolve
every dynamically constructed SAS program or rerun a complete research pipeline.

## Tests to rerun

```bash
# Offline source/dependency checks:
python tests/test_beta_macros.py
perl tests/test_beta_macros.pl
python tests/test_nested_include_graph.py
perl tests/test_nested_include_graph.pl

# Real SAS: positive fits and expected-failure guards:
python tests/test_beta_macros.py --live --guards --runner both --perl /path/to/perl --saspy-cfgname oda --saspy-cfgfile /path/to/sascfg_personal.py
```

`tests/beta_macro_regression.sas` generates 240 synthetic observations from 60
subjects using seed 926321. It fits the custom-column table and an equivalent
table with the original default column names. PROC COMPARE checks estimates and
standard errors within an absolute tolerance of 1e-7. The test also checks four
finite parameter estimates, 240 predictions, successful convergence, requested
output routing, and preservation of the caller's default table/macro variable.

Observed synthetic coefficients, rounded for readability, were b0=-0.4390,
b1=0.9060, a0=-1.0710 and s2g=0.6180. They are recorded software-test results,
not estimates from a biological study or universal expected values across SAS
versions. The automated comparison is between equivalent fits in the same run.

`tests/beta_macro_invalid_inputs.sas` separately tests missing input, a missing
predictor, counts greater than totals and an output that aliases the input. The
harness requires exit 1, the specific expected diagnostic and a safe
postcondition. Those expected failures are successful tests, not successful fits.

Actual results:

* Four positive submissions passed: Perl and Python on both SAS ODA and local
  Windows COM. Each submission fit both equivalent tables: eight fitted models.
  All six assertions passed per submission, without SAS errors or warnings.
* All eight ODA guard cases passed across both runners after the include fix.
  An additional local Windows Perl nested-include guard passed as expected.
* All 60 offline Perl regression scripts passed. The expanded include unit test
  subsequently passed all 16 assertions; its native Python counterpart passed
  two tests. Four Beta contract assertions also passed in Perl.
* The Python package regression suite passed 79 tests.

The original failure and first Perl guard failures are retained locally under
`SAS_Output_beta_review/`, alongside submitted programs, complete SAS logs, HTML,
execution JSON and the original macro backup. They are not counted as passes.
Hashes, actual case outcomes and installation provenance are recorded in
[the validation manifest](validation/beta-macro-20261115.json).

These tests validate software wiring, guards, convergence on the fixture and
rename invariance. They do not establish scientific calibration, adequate
covariate adjustment or suitability for any particular allelic-expression study.
No live Linux SAS installation was available; Windows and ODA execution evidence
is separate from cross-platform offline CI.

SAS references: [NLMIXED syntax and outputs](https://support.sas.com/documentation/cdl/en/statug/68162/HTML/default/statug_nlmixed_syntax.htm),
[the subject random-effect statement](https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/statug_nlmixed_sect019.htm),
[convergence-status interpretation](https://support.sas.com/documentation/cdl/en/statug/66103/HTML/default/statug_nlmixed_details33.htm),
and [FMM ODS tables](https://support.sas.com/documentation/cdl/en/statug/65328/HTML/default/statug_fmm_details32.htm).
