/* F1516 means_population_variance, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1516a; do x=1 to 7; output; end; run;
proc means data=f1516a noprint vardef=n; var x; output out=f1516o var=actual; run;

data _null_; if 0 then set f1516o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1516 rows=' rows;
else do; set f1516o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1516';
else put 'ERROR: ROUND4_FAIL=F1516 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1516:; quit;
