/* F1668 means_uncorrected_sum_squares, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1668a; do x=1 to 9; output; end; run;
proc means data=f1668a noprint; var x; output out=f1668o uss=actual; run;

data _null_; if 0 then set f1668o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1668 rows=' rows;
else do; set f1668o; if not missing(actual) and abs(actual-(285))<=1e-9*max(1,abs(285)) then put 'ROUND4_PASS=F1668';
else put 'ERROR: ROUND4_FAIL=F1668 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1668:; quit;
