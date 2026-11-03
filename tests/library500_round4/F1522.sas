/* F1522 means_standard_error, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1522a; do x=1 to 3; output; end; run;
proc means data=f1522a noprint; var x; output out=f1522o stderr=actual; run;

data _null_; if 0 then set f1522o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1522 rows=' rows;
else do; set f1522o; if not missing(actual) and abs(actual-(0.577350269189626))<=1e-9*max(1,abs(0.577350269189626)) then put 'ROUND4_PASS=F1522';
else put 'ERROR: ROUND4_FAIL=F1522 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1522:; quit;
