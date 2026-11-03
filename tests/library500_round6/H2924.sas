/* H2924 syscall_dataset_binding, N=5; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2924a; h2924x=5; h2924y=6; run;
%let h2924ds=%sysfunc(open(h2924a,i)); %syscall set(h2924ds);
%let h2924rc=%sysfunc(fetchobs(&h2924ds,1));
data h2924o; actual=&h2924x+&h2924y; run;
%let h2924rc=%sysfunc(close(&h2924ds)); %symdel h2924ds h2924rc h2924x h2924y;

data _null_; if 0 then set h2924o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2924 rows=' rows;
else do; set h2924o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2924';
else put 'ERROR: ROUND6_FAIL=H2924 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2924:; quit;
