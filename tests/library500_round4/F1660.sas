/* F1660 means_corrected_sum_squares, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1660a; do x=1 to 11; output; end; run;
proc means data=f1660a noprint; var x; output out=f1660o css=actual; run;

data _null_; if 0 then set f1660o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1660 rows=' rows;
else do; set f1660o; if not missing(actual) and abs(actual-(110))<=1e-9*max(1,abs(110)) then put 'ROUND4_PASS=F1660';
else put 'ERROR: ROUND4_FAIL=F1660 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1660:; quit;
