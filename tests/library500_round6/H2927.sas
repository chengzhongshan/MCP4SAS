/* H2927 syscall_dataset_binding, N=8; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2927a; h2927x=8; h2927y=9; run;
%let h2927ds=%sysfunc(open(h2927a,i)); %syscall set(h2927ds);
%let h2927rc=%sysfunc(fetchobs(&h2927ds,1));
data h2927o; actual=&h2927x+&h2927y; run;
%let h2927rc=%sysfunc(close(&h2927ds)); %symdel h2927ds h2927rc h2927x h2927y;

data _null_; if 0 then set h2927o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2927 rows=' rows;
else do; set h2927o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND6_PASS=H2927';
else put 'ERROR: ROUND6_FAIL=H2927 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2927:; quit;
