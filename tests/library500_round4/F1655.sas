/* F1655 means_corrected_sum_squares, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1655a; do x=1 to 6; output; end; run;
proc means data=f1655a noprint; var x; output out=f1655o css=actual; run;

data _null_; if 0 then set f1655o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1655 rows=' rows;
else do; set f1655o; if not missing(actual) and abs(actual-(17.5))<=1e-9*max(1,abs(17.5)) then put 'ROUND4_PASS=F1655';
else put 'ERROR: ROUND4_FAIL=F1655 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1655:; quit;
