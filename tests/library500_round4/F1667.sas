/* F1667 means_uncorrected_sum_squares, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1667a; do x=1 to 8; output; end; run;
proc means data=f1667a noprint; var x; output out=f1667o uss=actual; run;

data _null_; if 0 then set f1667o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1667 rows=' rows;
else do; set f1667o; if not missing(actual) and abs(actual-(204))<=1e-9*max(1,abs(204)) then put 'ROUND4_PASS=F1667';
else put 'ERROR: ROUND4_FAIL=F1667 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1667:; quit;
