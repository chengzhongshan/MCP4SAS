/* F1514 means_population_variance, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1514a; do x=1 to 5; output; end; run;
proc means data=f1514a noprint vardef=n; var x; output out=f1514o var=actual; run;

data _null_; if 0 then set f1514o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1514 rows=' rows;
else do; set f1514o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1514';
else put 'ERROR: ROUND4_FAIL=F1514 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1514:; quit;
