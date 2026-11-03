/* F1515 means_population_variance, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1515a; do x=1 to 6; output; end; run;
proc means data=f1515a noprint vardef=n; var x; output out=f1515o var=actual; run;

data _null_; if 0 then set f1515o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1515 rows=' rows;
else do; set f1515o; if not missing(actual) and abs(actual-(2.91666666666667))<=1e-9*max(1,abs(2.91666666666667)) then put 'ROUND4_PASS=F1515';
else put 'ERROR: ROUND4_FAIL=F1515 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1515:; quit;
