/* F1654 means_corrected_sum_squares, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1654a; do x=1 to 5; output; end; run;
proc means data=f1654a noprint; var x; output out=f1654o css=actual; run;

data _null_; if 0 then set f1654o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1654 rows=' rows;
else do; set f1654o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1654';
else put 'ERROR: ROUND4_FAIL=F1654 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1654:; quit;
