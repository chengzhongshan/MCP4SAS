/* F1546 means_sum_weights, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1546a; do x=1 to 7; weight=x; output; end; run;
proc means data=f1546a noprint; var x; weight weight; output out=f1546o sumwgt=actual; run;

data _null_; if 0 then set f1546o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1546 rows=' rows;
else do; set f1546o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND4_PASS=F1546';
else put 'ERROR: ROUND4_FAIL=F1546 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1546:; quit;
