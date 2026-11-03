/* F1542 means_sum_weights, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1542a; do x=1 to 3; weight=x; output; end; run;
proc means data=f1542a noprint; var x; weight weight; output out=f1542o sumwgt=actual; run;

data _null_; if 0 then set f1542o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1542 rows=' rows;
else do; set f1542o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1542';
else put 'ERROR: ROUND4_FAIL=F1542 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1542:; quit;
