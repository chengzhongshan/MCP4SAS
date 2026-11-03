/* F1669 means_uncorrected_sum_squares, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1669a; do x=1 to 10; output; end; run;
proc means data=f1669a noprint; var x; output out=f1669o uss=actual; run;

data _null_; if 0 then set f1669o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1669 rows=' rows;
else do; set f1669o; if not missing(actual) and abs(actual-(385))<=1e-9*max(1,abs(385)) then put 'ROUND4_PASS=F1669';
else put 'ERROR: ROUND4_FAIL=F1669 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1669:; quit;
