/* F1544 means_sum_weights, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1544a; do x=1 to 5; weight=x; output; end; run;
proc means data=f1544a noprint; var x; weight weight; output out=f1544o sumwgt=actual; run;

data _null_; if 0 then set f1544o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1544 rows=' rows;
else do; set f1544o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND4_PASS=F1544';
else put 'ERROR: ROUND4_FAIL=F1544 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1544:; quit;
