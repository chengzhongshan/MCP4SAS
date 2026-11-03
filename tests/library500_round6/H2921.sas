/* H2921 syscall_dataset_binding, N=2; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2921a; h2921x=2; h2921y=3; run;
%let h2921ds=%sysfunc(open(h2921a,i)); %syscall set(h2921ds);
%let h2921rc=%sysfunc(fetchobs(&h2921ds,1));
data h2921o; actual=&h2921x+&h2921y; run;
%let h2921rc=%sysfunc(close(&h2921ds)); %symdel h2921ds h2921rc h2921x h2921y;

data _null_; if 0 then set h2921o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2921 rows=' rows;
else do; set h2921o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2921';
else put 'ERROR: ROUND6_FAIL=H2921 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2921:; quit;
