/* F1550 means_sum_weights, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1550a; do x=1 to 11; weight=x; output; end; run;
proc means data=f1550a noprint; var x; weight weight; output out=f1550o sumwgt=actual; run;

data _null_; if 0 then set f1550o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1550 rows=' rows;
else do; set f1550o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND4_PASS=F1550';
else put 'ERROR: ROUND4_FAIL=F1550 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1550:; quit;
