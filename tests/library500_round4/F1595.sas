/* F1595 means_zero_weight_exclusion, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1595a; do x=1 to 6; weight=1; output; end; x=999; weight=0; output; run;
proc means data=f1595a noprint; var x; weight weight; output out=f1595o mean=actual; run;

data _null_; if 0 then set f1595o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1595 rows=' rows;
else do; set f1595o; if not missing(actual) and abs(actual-(3.5))<=1e-9*max(1,abs(3.5)) then put 'ROUND4_PASS=F1595';
else put 'ERROR: ROUND4_FAIL=F1595 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1595:; quit;
