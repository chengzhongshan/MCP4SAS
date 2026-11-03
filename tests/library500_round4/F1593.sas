/* F1593 means_zero_weight_exclusion, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1593a; do x=1 to 4; weight=1; output; end; x=999; weight=0; output; run;
proc means data=f1593a noprint; var x; weight weight; output out=f1593o mean=actual; run;

data _null_; if 0 then set f1593o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1593 rows=' rows;
else do; set f1593o; if not missing(actual) and abs(actual-(2.5))<=1e-9*max(1,abs(2.5)) then put 'ROUND4_PASS=F1593';
else put 'ERROR: ROUND4_FAIL=F1593 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1593:; quit;
