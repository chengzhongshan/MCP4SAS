/* F1666 means_uncorrected_sum_squares, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1666a; do x=1 to 7; output; end; run;
proc means data=f1666a noprint; var x; output out=f1666o uss=actual; run;

data _null_; if 0 then set f1666o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1666 rows=' rows;
else do; set f1666o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND4_PASS=F1666';
else put 'ERROR: ROUND4_FAIL=F1666 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1666:; quit;
