/* F1547 means_sum_weights, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1547a; do x=1 to 8; weight=x; output; end; run;
proc means data=f1547a noprint; var x; weight weight; output out=f1547o sumwgt=actual; run;

data _null_; if 0 then set f1547o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1547 rows=' rows;
else do; set f1547o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND4_PASS=F1547';
else put 'ERROR: ROUND4_FAIL=F1547 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1547:; quit;
