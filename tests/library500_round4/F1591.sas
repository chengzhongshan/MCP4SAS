/* F1591 means_zero_weight_exclusion, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1591a; do x=1 to 2; weight=1; output; end; x=999; weight=0; output; run;
proc means data=f1591a noprint; var x; weight weight; output out=f1591o mean=actual; run;

data _null_; if 0 then set f1591o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1591 rows=' rows;
else do; set f1591o; if not missing(actual) and abs(actual-(1.5))<=1e-9*max(1,abs(1.5)) then put 'ROUND4_PASS=F1591';
else put 'ERROR: ROUND4_FAIL=F1591 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1591:; quit;
