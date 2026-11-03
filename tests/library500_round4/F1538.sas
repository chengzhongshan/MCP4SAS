/* F1538 means_coefficient_variation, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1538a; do x=1 to 9; output; end; run;
proc means data=f1538a noprint; var x; output out=f1538o cv=actual; run;

data _null_; if 0 then set f1538o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1538 rows=' rows;
else do; set f1538o; if not missing(actual) and abs(actual-(54.7722557505166))<=1e-9*max(1,abs(54.7722557505166)) then put 'ROUND4_PASS=F1538';
else put 'ERROR: ROUND4_FAIL=F1538 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1538:; quit;
