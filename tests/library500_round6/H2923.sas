/* H2923 syscall_dataset_binding, N=4; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2923a; h2923x=4; h2923y=5; run;
%let h2923ds=%sysfunc(open(h2923a,i)); %syscall set(h2923ds);
%let h2923rc=%sysfunc(fetchobs(&h2923ds,1));
data h2923o; actual=&h2923x+&h2923y; run;
%let h2923rc=%sysfunc(close(&h2923ds)); %symdel h2923ds h2923rc h2923x h2923y;

data _null_; if 0 then set h2923o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2923 rows=' rows;
else do; set h2923o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2923';
else put 'ERROR: ROUND6_FAIL=H2923 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2923:; quit;
