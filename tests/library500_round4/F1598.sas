/* F1598 means_zero_weight_exclusion, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1598a; do x=1 to 9; weight=1; output; end; x=999; weight=0; output; run;
proc means data=f1598a noprint; var x; weight weight; output out=f1598o mean=actual; run;

data _null_; if 0 then set f1598o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1598 rows=' rows;
else do; set f1598o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1598';
else put 'ERROR: ROUND4_FAIL=F1598 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1598:; quit;
