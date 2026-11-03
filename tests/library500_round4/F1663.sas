/* F1663 means_uncorrected_sum_squares, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1663a; do x=1 to 4; output; end; run;
proc means data=f1663a noprint; var x; output out=f1663o uss=actual; run;

data _null_; if 0 then set f1663o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1663 rows=' rows;
else do; set f1663o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND4_PASS=F1663';
else put 'ERROR: ROUND4_FAIL=F1663 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1663:; quit;
