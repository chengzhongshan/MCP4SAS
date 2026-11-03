/* F1651 means_corrected_sum_squares, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1651a; do x=1 to 2; output; end; run;
proc means data=f1651a noprint; var x; output out=f1651o css=actual; run;

data _null_; if 0 then set f1651o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1651 rows=' rows;
else do; set f1651o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND4_PASS=F1651';
else put 'ERROR: ROUND4_FAIL=F1651 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1651:; quit;
