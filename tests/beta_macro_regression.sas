/* Synthetic software regression. Not a real allelic-expression study. */
%include "examples/sas_macros/scASE_betabino.sas";
data beta_fixture;
 call streaminit(926321);
 do donor_id=1 to 60;
   donor_effect=rand('normal',0,0.8);
   do replicate=1 to 4;
     exposure=mod(replicate,2);
     total_reads=35+mod(donor_id+replicate,20);
     mean=1/(1+exp(-(-0.6+0.9*exposure+donor_effect)));
     sampled_p=rand('beta',mean*20,(1-mean)*20);
     alternate_reads=rand('binomial',sampled_p,total_reads);
     shuffle=rand('uniform'); output;
   end;
 end;
 keep donor_id exposure total_reads alternate_reads shuffle;
run;
proc sort data=beta_fixture; by shuffle; run;
data nlmParameterEstimates; sentinel=42; run;
%let b0_fmm_val=caller_value;

%scASE_betabino(dsdin=beta_fixture,model_var=exposure,subj_var=donor_id,
                read_var=alternate_reads,tot_var=total_reads,
                outdsd=custom_estimates,predout=custom_predictions,statusout=custom_status);
data beta_default_names;
 set beta_fixture(rename=(exposure=x donor_id=subj alternate_reads=A_cnt total_reads=tot));
run;
%scASE_betabino(dsdin=beta_default_names,outdsd=reference_estimates,
                predout=reference_predictions,statusout=reference_status);

proc sort data=custom_estimates; by Parameter; run;
proc sort data=reference_estimates; by Parameter; run;
proc compare base=reference_estimates compare=custom_estimates criterion=1e-7 method=absolute noprint;
 id Parameter; var Estimate StandardError;
run;
%let beta_compare_status=&sysinfo;
proc sql noprint;
 select count(*) into :beta_estimate_n trimmed from custom_estimates where not missing(Estimate);
 select count(*) into :beta_prediction_n trimmed from custom_predictions;
 select min(Status) into :beta_convergence trimmed from custom_status;
 select count(*) into :beta_sentinel_n trimmed from nlmParameterEstimates where sentinel=42;
quit;
%macro _beta_assert(condition=,label=);
 %if &condition %then %put BETA_TEST_PASS=&label;
 %else %put ERROR: BETA_TEST_FAIL=&label;
%mend;
%_beta_assert(condition=&beta_compare_status=0,label=renamed_predictor_compare);
%_beta_assert(condition=&beta_estimate_n=4,label=custom_output_has_four_parameters);
%_beta_assert(condition=&beta_prediction_n=240,label=one_prediction_per_input_row);
%_beta_assert(condition=&beta_convergence=0,label=nlmixed_converged);
%_beta_assert(condition=&beta_sentinel_n=1,label=requested_output_preserves_default_table);
%_beta_assert(condition=%superq(b0_fmm_val)=caller_value,label=initializer_macro_variable_preserved);
%put BETA_REGRESSION_COMPLETE;
