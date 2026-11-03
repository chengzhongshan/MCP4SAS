/* F1597 means_zero_weight_exclusion, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1597a; do x=1 to 8; weight=1; output; end; x=999; weight=0; output; run;
proc means data=f1597a noprint; var x; weight weight; output out=f1597o mean=actual; run;

data _null_; if 0 then set f1597o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1597 rows=' rows;
else do; set f1597o; if not missing(actual) and abs(actual-(4.5))<=1e-9*max(1,abs(4.5)) then put 'ROUND4_PASS=F1597';
else put 'ERROR: ROUND4_FAIL=F1597 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1597:; quit;
