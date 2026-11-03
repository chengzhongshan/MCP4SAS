/* F1524 means_standard_error, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1524a; do x=1 to 5; output; end; run;
proc means data=f1524a noprint; var x; output out=f1524o stderr=actual; run;

data _null_; if 0 then set f1524o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1524 rows=' rows;
else do; set f1524o; if not missing(actual) and abs(actual-(0.707106781186548))<=1e-9*max(1,abs(0.707106781186548)) then put 'ROUND4_PASS=F1524';
else put 'ERROR: ROUND4_FAIL=F1524 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1524:; quit;
