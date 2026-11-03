/* F1520 means_population_variance, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1520a; do x=1 to 11; output; end; run;
proc means data=f1520a noprint vardef=n; var x; output out=f1520o var=actual; run;

data _null_; if 0 then set f1520o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1520 rows=' rows;
else do; set f1520o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1520';
else put 'ERROR: ROUND4_FAIL=F1520 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1520:; quit;
