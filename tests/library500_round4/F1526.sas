/* F1526 means_standard_error, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1526a; do x=1 to 7; output; end; run;
proc means data=f1526a noprint; var x; output out=f1526o stderr=actual; run;

data _null_; if 0 then set f1526o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1526 rows=' rows;
else do; set f1526o; if not missing(actual) and abs(actual-(0.816496580927726))<=1e-9*max(1,abs(0.816496580927726)) then put 'ROUND4_PASS=F1526';
else put 'ERROR: ROUND4_FAIL=F1526 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1526:; quit;
