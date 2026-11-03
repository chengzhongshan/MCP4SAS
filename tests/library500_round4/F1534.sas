/* F1534 means_coefficient_variation, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1534a; do x=1 to 5; output; end; run;
proc means data=f1534a noprint; var x; output out=f1534o cv=actual; run;

data _null_; if 0 then set f1534o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1534 rows=' rows;
else do; set f1534o; if not missing(actual) and abs(actual-(52.704627669473))<=1e-9*max(1,abs(52.704627669473)) then put 'ROUND4_PASS=F1534';
else put 'ERROR: ROUND4_FAIL=F1534 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1534:; quit;
