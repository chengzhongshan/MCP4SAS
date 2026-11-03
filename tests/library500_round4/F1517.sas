/* F1517 means_population_variance, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1517a; do x=1 to 8; output; end; run;
proc means data=f1517a noprint vardef=n; var x; output out=f1517o var=actual; run;

data _null_; if 0 then set f1517o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1517 rows=' rows;
else do; set f1517o; if not missing(actual) and abs(actual-(5.25))<=1e-9*max(1,abs(5.25)) then put 'ROUND4_PASS=F1517';
else put 'ERROR: ROUND4_FAIL=F1517 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1517:; quit;
