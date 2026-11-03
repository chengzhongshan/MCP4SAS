/* F1548 means_sum_weights, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1548a; do x=1 to 9; weight=x; output; end; run;
proc means data=f1548a noprint; var x; weight weight; output out=f1548o sumwgt=actual; run;

data _null_; if 0 then set f1548o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1548 rows=' rows;
else do; set f1548o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND4_PASS=F1548';
else put 'ERROR: ROUND4_FAIL=F1548 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1548:; quit;
