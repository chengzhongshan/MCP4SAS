/* One isolated validation case per submission; expected ERROR, no fitting. */
%include "examples/sas_macros/scASE_betabino.sas";
%macro _beta_invalid_fixture;
 %local _case _input _predictor _output _after_n _after_status;
 %if %symexist(beta_invalid_case) %then %let _case=&beta_invalid_case;
 %else %let _case=missing_input;
 data beta_negative_input;
   subject=1; predictor=0; alternate=2; total=8;
   %if &_case=invalid_counts %then %do; alternate=9; %end;
 run;
 data beta_negative_output; stale=42; run;
 %let _input=beta_negative_input;
 %let _predictor=predictor;
 %let _output=beta_negative_output;
 %if &_case=missing_input %then %let _input=__beta_missing_input__;
 %if &_case=missing_predictor %then %let _predictor=absent_predictor;
 %if &_case=output_overlap %then %let _output=work.beta_negative_input;
 %scASE_betabino(dsdin=&_input,model_var=&_predictor,subj_var=subject,
                 read_var=alternate,tot_var=total,outdsd=&_output,
                 predout=beta_negative_predictions,statusout=beta_negative_status);
 %if &_case=output_overlap %then %do;
   proc sql noprint;
     select count(*) into :_after_n trimmed from beta_negative_input where alternate=2 and total=8;
   quit;
   %if &_after_n=1 %then %put BETA_GUARD_PASS=&_case;
   %else %put ERROR: BETA_GUARD_ASSERT: input was changed.;
 %end;
 %else %do;
   proc sql noprint;
     select count(*) into :_after_n trimmed from beta_negative_output;
     select min(Status) into :_after_status trimmed from beta_negative_status;
   quit;
   %if &_after_n=0 and &_after_status=999 %then %put BETA_GUARD_PASS=&_case;
   %else %put ERROR: BETA_GUARD_ASSERT: stale estimates or success status remained.;
 %end;
%mend;
%_beta_invalid_fixture;
