/* F1513 means_population_variance, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1513a; do x=1 to 4; output; end; run;
proc means data=f1513a noprint vardef=n; var x; output out=f1513o var=actual; run;

data _null_; if 0 then set f1513o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1513 rows=' rows;
else do; set f1513o; if not missing(actual) and abs(actual-(1.25))<=1e-9*max(1,abs(1.25)) then put 'ROUND4_PASS=F1513';
else put 'ERROR: ROUND4_FAIL=F1513 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1513:; quit;
