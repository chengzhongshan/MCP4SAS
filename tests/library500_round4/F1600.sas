/* F1600 means_zero_weight_exclusion, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1600a; do x=1 to 11; weight=1; output; end; x=999; weight=0; output; run;
proc means data=f1600a noprint; var x; weight weight; output out=f1600o mean=actual; run;

data _null_; if 0 then set f1600o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1600 rows=' rows;
else do; set f1600o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1600';
else put 'ERROR: ROUND4_FAIL=F1600 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1600:; quit;
