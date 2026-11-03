/* H2928 syscall_dataset_binding, N=9; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2928a; h2928x=9; h2928y=10; run;
%let h2928ds=%sysfunc(open(h2928a,i)); %syscall set(h2928ds);
%let h2928rc=%sysfunc(fetchobs(&h2928ds,1));
data h2928o; actual=&h2928x+&h2928y; run;
%let h2928rc=%sysfunc(close(&h2928ds)); %symdel h2928ds h2928rc h2928x h2928y;

data _null_; if 0 then set h2928o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2928 rows=' rows;
else do; set h2928o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND6_PASS=H2928';
else put 'ERROR: ROUND6_FAIL=H2928 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2928:; quit;
