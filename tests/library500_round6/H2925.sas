/* H2925 syscall_dataset_binding, N=6; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2925a; h2925x=6; h2925y=7; run;
%let h2925ds=%sysfunc(open(h2925a,i)); %syscall set(h2925ds);
%let h2925rc=%sysfunc(fetchobs(&h2925ds,1));
data h2925o; actual=&h2925x+&h2925y; run;
%let h2925rc=%sysfunc(close(&h2925ds)); %symdel h2925ds h2925rc h2925x h2925y;

data _null_; if 0 then set h2925o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2925 rows=' rows;
else do; set h2925o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND6_PASS=H2925';
else put 'ERROR: ROUND6_FAIL=H2925 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2925:; quit;
