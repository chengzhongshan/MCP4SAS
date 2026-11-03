/* F1527 means_standard_error, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1527a; do x=1 to 8; output; end; run;
proc means data=f1527a noprint; var x; output out=f1527o stderr=actual; run;

data _null_; if 0 then set f1527o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1527 rows=' rows;
else do; set f1527o; if not missing(actual) and abs(actual-(0.866025403784439))<=1e-9*max(1,abs(0.866025403784439)) then put 'ROUND4_PASS=F1527';
else put 'ERROR: ROUND4_FAIL=F1527 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1527:; quit;
