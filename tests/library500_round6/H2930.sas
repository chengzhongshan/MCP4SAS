/* H2930 syscall_dataset_binding, N=11; source: SAS-Useful-Codes/Macros/base4sas_developer/mf_getkeyvalue.sas:22 */

data h2930a; h2930x=11; h2930y=12; run;
%let h2930ds=%sysfunc(open(h2930a,i)); %syscall set(h2930ds);
%let h2930rc=%sysfunc(fetchobs(&h2930ds,1));
data h2930o; actual=&h2930x+&h2930y; run;
%let h2930rc=%sysfunc(close(&h2930ds)); %symdel h2930ds h2930rc h2930x h2930y;

data _null_; if 0 then set h2930o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2930 rows=' rows;
else do; set h2930o; if not missing(actual) and abs(actual-(23))<=1e-9*max(1,abs(23)) then put 'ROUND6_PASS=H2930';
else put 'ERROR: ROUND6_FAIL=H2930 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2930:; quit;
