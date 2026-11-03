/* F1549 means_sum_weights, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1549a; do x=1 to 10; weight=x; output; end; run;
proc means data=f1549a noprint; var x; weight weight; output out=f1549o sumwgt=actual; run;

data _null_; if 0 then set f1549o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1549 rows=' rows;
else do; set f1549o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND4_PASS=F1549';
else put 'ERROR: ROUND4_FAIL=F1549 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1549:; quit;
