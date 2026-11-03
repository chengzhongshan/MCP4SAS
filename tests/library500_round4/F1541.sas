/* F1541 means_sum_weights, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1541a; do x=1 to 2; weight=x; output; end; run;
proc means data=f1541a noprint; var x; weight weight; output out=f1541o sumwgt=actual; run;

data _null_; if 0 then set f1541o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1541 rows=' rows;
else do; set f1541o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1541';
else put 'ERROR: ROUND4_FAIL=F1541 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1541:; quit;
