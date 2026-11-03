/* F1545 means_sum_weights, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1545a; do x=1 to 6; weight=x; output; end; run;
proc means data=f1545a noprint; var x; weight weight; output out=f1545o sumwgt=actual; run;

data _null_; if 0 then set f1545o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1545 rows=' rows;
else do; set f1545o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND4_PASS=F1545';
else put 'ERROR: ROUND4_FAIL=F1545 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1545:; quit;
