/* F1652 means_corrected_sum_squares, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1652a; do x=1 to 3; output; end; run;
proc means data=f1652a noprint; var x; output out=f1652o css=actual; run;

data _null_; if 0 then set f1652o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1652 rows=' rows;
else do; set f1652o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1652';
else put 'ERROR: ROUND4_FAIL=F1652 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1652:; quit;
