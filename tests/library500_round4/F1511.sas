/* F1511 means_population_variance, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1511a; do x=1 to 2; output; end; run;
proc means data=f1511a noprint vardef=n; var x; output out=f1511o var=actual; run;

data _null_; if 0 then set f1511o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1511 rows=' rows;
else do; set f1511o; if not missing(actual) and abs(actual-(0.25))<=1e-9*max(1,abs(0.25)) then put 'ROUND4_PASS=F1511';
else put 'ERROR: ROUND4_FAIL=F1511 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1511:; quit;
