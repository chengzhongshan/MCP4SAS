/* F1504 means_sample_variance, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1504a; do x=1 to 5; output; end; run;
proc means data=f1504a noprint; var x; output out=f1504o var=actual; run;

data _null_; if 0 then set f1504o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1504 rows=' rows;
else do; set f1504o; if not missing(actual) and abs(actual-(2.5))<=1e-9*max(1,abs(2.5)) then put 'ROUND4_PASS=F1504';
else put 'ERROR: ROUND4_FAIL=F1504 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1504:; quit;
