/* F1543 means_sum_weights, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1543a; do x=1 to 4; weight=x; output; end; run;
proc means data=f1543a noprint; var x; weight weight; output out=f1543o sumwgt=actual; run;

data _null_; if 0 then set f1543o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1543 rows=' rows;
else do; set f1543o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1543';
else put 'ERROR: ROUND4_FAIL=F1543 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1543:; quit;
