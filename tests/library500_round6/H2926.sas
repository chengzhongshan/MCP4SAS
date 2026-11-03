/* H2926 syscall_dataset_binding, N=7; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2926a; h2926x=7; h2926y=8; run;
%let h2926ds=%sysfunc(open(h2926a,i)); %syscall set(h2926ds);
%let h2926rc=%sysfunc(fetchobs(&h2926ds,1));
data h2926o; actual=&h2926x+&h2926y; run;
%let h2926rc=%sysfunc(close(&h2926ds)); %symdel h2926ds h2926rc h2926x h2926y;

data _null_; if 0 then set h2926o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2926 rows=' rows;
else do; set h2926o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND6_PASS=H2926';
else put 'ERROR: ROUND6_FAIL=H2926 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2926:; quit;
