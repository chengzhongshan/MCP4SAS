/* F1664 means_uncorrected_sum_squares, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1664a; do x=1 to 5; output; end; run;
proc means data=f1664a noprint; var x; output out=f1664o uss=actual; run;

data _null_; if 0 then set f1664o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1664 rows=' rows;
else do; set f1664o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND4_PASS=F1664';
else put 'ERROR: ROUND4_FAIL=F1664 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1664:; quit;
