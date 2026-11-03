/* F1592 means_zero_weight_exclusion, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1592a; do x=1 to 3; weight=1; output; end; x=999; weight=0; output; run;
proc means data=f1592a noprint; var x; weight weight; output out=f1592o mean=actual; run;

data _null_; if 0 then set f1592o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1592 rows=' rows;
else do; set f1592o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1592';
else put 'ERROR: ROUND4_FAIL=F1592 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1592:; quit;
