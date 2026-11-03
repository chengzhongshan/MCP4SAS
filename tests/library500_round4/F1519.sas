/* F1519 means_population_variance, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1519a; do x=1 to 10; output; end; run;
proc means data=f1519a noprint vardef=n; var x; output out=f1519o var=actual; run;

data _null_; if 0 then set f1519o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1519 rows=' rows;
else do; set f1519o; if not missing(actual) and abs(actual-(8.25))<=1e-9*max(1,abs(8.25)) then put 'ROUND4_PASS=F1519';
else put 'ERROR: ROUND4_FAIL=F1519 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1519:; quit;
