/* Test-only namespaced definition from char2num_dsd.sas; original SHA256 67b58b47d8b699190bf4159304631c5176f00a20ddb58b4719ee28d19601288b. */
%macro n26_char2num_dsd(dsdin,vars,dsdout);
%let nv=%eval(%sysfunc(count(&vars,%str( )))+1);
%if %index(&vars,%str( )) %then %do;
 %let _vars_=%sysfunc(prxchange(s/ /__ __/,-1,&vars));
%end;
%else %do;
 %let _vars_=%sysfunc(prxchange(s/^/__/,-1,&vars));
%end;

%put old vars are &vars;
%put temperary new vars are &_vars_;
data &dsdout(
  rename=(
  %let n=1;
  %do %while (&n<=&nv);
      %let old0=%scan(&_vars_,&n);
      %let new0=%scan(&vars,&n);
       &old0=&new0 
   %let n=%eval(&n+1);
  %end;
 )
);
set &dsdin;

  %let n=1;
  %do %while (&n<=&nv);
   %let old=%scan(&_vars_,&n);
   %let new=%scan(&vars,&n);
     &old=&new+0;
   %let n=%eval(&n+1);
  %end;

drop &vars;
run;

%mend;
