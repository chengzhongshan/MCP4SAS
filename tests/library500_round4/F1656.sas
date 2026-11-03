/* F1656 means_corrected_sum_squares, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1656a; do x=1 to 7; output; end; run;
proc means data=f1656a noprint; var x; output out=f1656o css=actual; run;

data _null_; if 0 then set f1656o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1656 rows=' rows;
else do; set f1656o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND4_PASS=F1656';
else put 'ERROR: ROUND4_FAIL=F1656 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1656:; quit;
