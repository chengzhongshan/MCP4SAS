/* F1596 means_zero_weight_exclusion, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1596a; do x=1 to 7; weight=1; output; end; x=999; weight=0; output; run;
proc means data=f1596a noprint; var x; weight weight; output out=f1596o mean=actual; run;

data _null_; if 0 then set f1596o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1596 rows=' rows;
else do; set f1596o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1596';
else put 'ERROR: ROUND4_FAIL=F1596 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1596:; quit;
