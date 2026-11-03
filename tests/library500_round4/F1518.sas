/* F1518 means_population_variance, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1518a; do x=1 to 9; output; end; run;
proc means data=f1518a noprint vardef=n; var x; output out=f1518o var=actual; run;

data _null_; if 0 then set f1518o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1518 rows=' rows;
else do; set f1518o; if not missing(actual) and abs(actual-(6.66666666666667))<=1e-9*max(1,abs(6.66666666666667)) then put 'ROUND4_PASS=F1518';
else put 'ERROR: ROUND4_FAIL=F1518 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1518:; quit;
