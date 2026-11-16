/* Repair of Zhongshan Cheng's single-predictor beta-binomial mixed model.
   Preserve the original FMM initializer, beta-binomial likelihood, rho/phi
   parameterization and normal subject random intercept. No categorical CLASS
   effects are implemented: model_var must name one numeric predictor.
   New optional outputs: predout (previously always prob_vals) and statusout.
*/
%macro scASE_betabino(dsdin=x2,model_var=x,subj_var=subj,read_var=A_cnt,
                     tot_var=tot,outdsd=nlmParameterEstimates,
                     predout=prob_vals,statusout=);
%local _sc_tag _sc_data _sc_fmm _sc_fmmstatus _sc_status _sc_valid _sc_dsid
       _sc_rc _sc_j _sc_name _sc_vnum _sc_bad _sc_n _sc_b0 _sc_b1 _sc_ok _sc_init_ok;
%let _sc_tag=_sc%substr(%sysfunc(compress(%sysfunc(uuidgen()),-)),1,10);
%let _sc_data=&_sc_tag.d;
%let _sc_fmm=&_sc_tag.f;
%let _sc_fmmstatus=&_sc_tag.i;
%let _sc_status=&_sc_tag.c;
%if %length(%superq(statusout)) %then %let _sc_status=&statusout;
%let _sc_valid=1;
%let _sc_b0=;
%let _sc_b1=;
data _null_;
 length name source target $100;
 array output_names[3] $100 _temporary_;
 source=upcase(symget('dsdin'));
 if not index(source,'.') then source=cats('WORK.',source);
 do item=1 to 4;
   name=symget(scan('dsdin outdsd predout _sc_status',item));
   if not prxmatch('/^([A-Za-z_][A-Za-z0-9_]{0,7}\.)?[A-Za-z_][A-Za-z0-9_]{0,31}$/',strip(name)) then do;
     put 'ERROR: SCASE_INVALID_DATASET_NAME: use V7 dataset names.';
     call symputx('_sc_valid',0,'L');
   end;
   if item>1 then do;
     target=upcase(name);
     if not index(target,'.') then target=cats('WORK.',target);
     if target=source then do;
       put 'ERROR: SCASE_OUTPUT_OVERLAPS_INPUT: output datasets must differ from input.';
       call symputx('_sc_valid',0,'L');
     end;
     do previous=1 to item-2;
       if target=output_names[previous] then do;
         put 'ERROR: SCASE_OUTPUT_COLLISION: estimate, prediction and status outputs must differ.';
         call symputx('_sc_valid',0,'L');
       end;
     end;
     output_names[item-1]=target;
   end;
 end;
 do item=1 to 4;
   name=symget(scan('model_var subj_var read_var tot_var',item));
   if not prxmatch('/^[A-Za-z_][A-Za-z0-9_]{0,31}$/',strip(name)) then do;
     put 'ERROR: SCASE_INVALID_VARIABLE: supply one V7 variable name per parameter.';
     call symputx('_sc_valid',0,'L');
   end;
 end;
run;
%if not &_sc_valid %then %return;
/* A rejected rerun must not leave a previous estimate/status looking current. */
data &outdsd;
 length Parameter $32 Estimate 8;
 call missing(Parameter,Estimate); stop;
run;
data &predout;
 length Pred 8; call missing(Pred); stop;
run;
data &_sc_status;
 length Status 8 Reason $200;
 Status=999; Reason='Not fitted: inspect input validation and SAS log';
run;
%if not %sysfunc(exist(&dsdin)) %then %do;
 %put ERROR: SCASE_MISSING_INPUT: input dataset &dsdin does not exist.;
 %goto finish;
%end;
%let _sc_dsid=%sysfunc(open(&dsdin,i));
%if not &_sc_dsid %then %do;
 %put ERROR: SCASE_INPUT_UNREADABLE: input dataset &dsdin cannot be opened.;
 %goto finish;
%end;
%do _sc_j=1 %to 4;
 %let _sc_name=%scan(&model_var &subj_var &read_var &tot_var,&_sc_j);
 %let _sc_vnum=%sysfunc(varnum(&_sc_dsid,&_sc_name));
 %if not &_sc_vnum %then %do;
   %put ERROR: SCASE_MISSING_VARIABLE: &_sc_name is not in &dsdin.;
   %let _sc_valid=0;
 %end;
 %else %if &_sc_j ne 2 %then %do;
   %if %sysfunc(vartype(&_sc_dsid,&_sc_vnum)) ne N %then %do;
     %put ERROR: SCASE_NONNUMERIC_VARIABLE: &_sc_name must be numeric.;
     %let _sc_valid=0;
   %end;
 %end;
%end;
%let _sc_rc=%sysfunc(close(&_sc_dsid));
%if not &_sc_valid %then %goto finish;
/* Validate counts before fitting; do not silently discard problematic rows. */
proc sql noprint;
 select count(*),
        coalesce(sum(cmiss(&model_var,&subj_var,&read_var,&tot_var)>0
          or &tot_var<=0 or &read_var<0 or &read_var>&tot_var
          or &read_var ne floor(&read_var) or &tot_var ne floor(&tot_var)),0)
 into :_sc_n trimmed,:_sc_bad trimmed from &dsdin;
quit;
%if &_sc_n=0 or &_sc_bad>0 %then %do;
 %put ERROR: SCASE_INVALID_COUNTS: require complete rows and integer counts 0<=read_var<=tot_var with tot_var>0.;
 %goto finish;
%end;
/* Copy/sort rather than changing the caller's order. Older SAS releases require
   observations to be contiguous within the NLMIXED SUBJECT variable. */
proc sort data=&dsdin out=work.&_sc_data; by &subj_var; run;
ods output ParameterEstimates=work.&_sc_fmm ConvergenceStatus=work.&_sc_fmmstatus;
proc fmm data=work.&_sc_data;
 model &read_var/&tot_var=&model_var / dist=betabinomial;
run;
ods output close;
%if not %sysfunc(exist(work.&_sc_fmm)) %then %do;
 %put ERROR: SCASE_INITIALIZER_FAILED: FMM did not return parameter estimates.;
 %goto finish;
%end;
%let _sc_init_ok=0;
%if %sysfunc(exist(work.&_sc_fmmstatus)) %then %do;
 data _null_;
   set work.&_sc_fmmstatus;
   if Status=0 then call symputx('_sc_init_ok',1,'L');
 run;
%end;
%if not &_sc_init_ok %then %do;
 %put ERROR: SCASE_INITIALIZER_FAILED: inspect FMM convergence before fitting the mixed model.;
 %goto finish;
%end;
proc sql noprint;
 select Estimate into :_sc_b0 trimmed from work.&_sc_fmm
 where upcase(Effect)='INTERCEPT';
 select Estimate into :_sc_b1 trimmed from work.&_sc_fmm
 where upcase(Effect)=upcase("&model_var");
quit;
%if not %length(%superq(_sc_b0)) or not %length(%superq(_sc_b1)) %then %do;
 %put ERROR: SCASE_INITIALIZER_FAILED: FMM did not supply both requested coefficients.;
 %goto finish;
%end;
ods output ParameterEstimates=&outdsd ConvergenceStatus=&_sc_status;
proc nlmixed data=work.&_sc_data qfac=1 update=bfgs qmax=50 tech=quanew;
 parms b0=&_sc_b0 b1=&_sc_b1 a0=0.5 s2g=0.1;
 bounds s2g>=0;
 linr=a0;
 rho=1/(1+exp(-linr));
 phi=(1-rho**2)/(rho**2);
 eta=b0+b1*&model_var+u;
 p=1/(1+exp(-eta));
 n=&tot_var;
 y=&read_var;
 loglike=lgamma(n+1)-lgamma(y+1)-lgamma(n-y+1)+lgamma(phi)
         -lgamma(n+phi)+lgamma(y+phi*p)+lgamma(n-y+phi*(1-p))
         -lgamma(phi*p)-lgamma(phi*(1-p));
 model y~general(loglike);
 random u~normal(0,s2g) subject=&subj_var;
 predict p out=&predout;
run;
ods output close;
%let _sc_ok=0;
%if %sysfunc(exist(&_sc_status)) %then %do;
 data _null_;
   set &_sc_status;
   if Status=0 then call symputx('_sc_ok',1,'L');
 run;
%end;
%if not &_sc_ok %then %put ERROR: SCASE_NONCONVERGENCE: inspect the NLMIXED log and status output before interpreting estimates.;
%finish:
proc datasets library=work nolist;
 %do _sc_j=1 %to 3;
   %let _sc_name=%scan(&_sc_data &_sc_fmm &_sc_fmmstatus,&_sc_j);
   %if %sysfunc(exist(work.&_sc_name)) %then %do;
   delete &_sc_name;
   %end;
 %end;
 %if not %length(%superq(statusout)) and %sysfunc(exist(work.&_sc_status)) %then %do;
 delete &_sc_status;
 %end;
quit;
%mend scASE_betabino;
