/* F1594 means_zero_weight_exclusion, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1594a; do x=1 to 5; weight=1; output; end; x=999; weight=0; output; run;
proc means data=f1594a noprint; var x; weight weight; output out=f1594o mean=actual; run;

data _null_; if 0 then set f1594o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1594 rows=' rows;
else do; set f1594o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1594';
else put 'ERROR: ROUND4_FAIL=F1594 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1594:; quit;
