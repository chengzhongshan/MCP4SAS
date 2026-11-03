/* H2922 syscall_dataset_binding, N=3; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2922a; h2922x=3; h2922y=4; run;
%let h2922ds=%sysfunc(open(h2922a,i)); %syscall set(h2922ds);
%let h2922rc=%sysfunc(fetchobs(&h2922ds,1));
data h2922o; actual=&h2922x+&h2922y; run;
%let h2922rc=%sysfunc(close(&h2922ds)); %symdel h2922ds h2922rc h2922x h2922y;

data _null_; if 0 then set h2922o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2922 rows=' rows;
else do; set h2922o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2922';
else put 'ERROR: ROUND6_FAIL=H2922 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2922:; quit;
