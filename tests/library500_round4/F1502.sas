/* F1502 means_sample_variance, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1502a; do x=1 to 3; output; end; run;
proc means data=f1502a noprint; var x; output out=f1502o var=actual; run;

data _null_; if 0 then set f1502o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1502 rows=' rows;
else do; set f1502o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND4_PASS=F1502';
else put 'ERROR: ROUND4_FAIL=F1502 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1502:; quit;
