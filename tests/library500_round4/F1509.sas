/* F1509 means_sample_variance, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1509a; do x=1 to 10; output; end; run;
proc means data=f1509a noprint; var x; output out=f1509o var=actual; run;

data _null_; if 0 then set f1509o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1509 rows=' rows;
else do; set f1509o; if not missing(actual) and abs(actual-(9.16666666666667))<=1e-9*max(1,abs(9.16666666666667)) then put 'ROUND4_PASS=F1509';
else put 'ERROR: ROUND4_FAIL=F1509 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1509:; quit;
