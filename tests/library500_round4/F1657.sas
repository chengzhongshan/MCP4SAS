/* F1657 means_corrected_sum_squares, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1657a; do x=1 to 8; output; end; run;
proc means data=f1657a noprint; var x; output out=f1657o css=actual; run;

data _null_; if 0 then set f1657o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1657 rows=' rows;
else do; set f1657o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND4_PASS=F1657';
else put 'ERROR: ROUND4_FAIL=F1657 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1657:; quit;
