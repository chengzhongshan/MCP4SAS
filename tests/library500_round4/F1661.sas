/* F1661 means_uncorrected_sum_squares, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1661a; do x=1 to 2; output; end; run;
proc means data=f1661a noprint; var x; output out=f1661o uss=actual; run;

data _null_; if 0 then set f1661o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1661 rows=' rows;
else do; set f1661o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1661';
else put 'ERROR: ROUND4_FAIL=F1661 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1661:; quit;
