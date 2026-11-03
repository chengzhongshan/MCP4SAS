/* F1653 means_corrected_sum_squares, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1653a; do x=1 to 4; output; end; run;
proc means data=f1653a noprint; var x; output out=f1653o css=actual; run;

data _null_; if 0 then set f1653o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1653 rows=' rows;
else do; set f1653o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1653';
else put 'ERROR: ROUND4_FAIL=F1653 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1653:; quit;
