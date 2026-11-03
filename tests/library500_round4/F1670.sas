/* F1670 means_uncorrected_sum_squares, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1670a; do x=1 to 11; output; end; run;
proc means data=f1670a noprint; var x; output out=f1670o uss=actual; run;

data _null_; if 0 then set f1670o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1670 rows=' rows;
else do; set f1670o; if not missing(actual) and abs(actual-(506))<=1e-9*max(1,abs(506)) then put 'ROUND4_PASS=F1670';
else put 'ERROR: ROUND4_FAIL=F1670 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1670:; quit;
