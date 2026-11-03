/* F1658 means_corrected_sum_squares, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1658a; do x=1 to 9; output; end; run;
proc means data=f1658a noprint; var x; output out=f1658o css=actual; run;

data _null_; if 0 then set f1658o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1658 rows=' rows;
else do; set f1658o; if not missing(actual) and abs(actual-(60))<=1e-9*max(1,abs(60)) then put 'ROUND4_PASS=F1658';
else put 'ERROR: ROUND4_FAIL=F1658 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1658:; quit;
