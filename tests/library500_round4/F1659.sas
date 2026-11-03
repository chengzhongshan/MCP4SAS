/* F1659 means_corrected_sum_squares, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1659a; do x=1 to 10; output; end; run;
proc means data=f1659a noprint; var x; output out=f1659o css=actual; run;

data _null_; if 0 then set f1659o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1659 rows=' rows;
else do; set f1659o; if not missing(actual) and abs(actual-(82.5))<=1e-9*max(1,abs(82.5)) then put 'ROUND4_PASS=F1659';
else put 'ERROR: ROUND4_FAIL=F1659 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1659:; quit;
