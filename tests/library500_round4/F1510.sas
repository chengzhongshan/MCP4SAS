/* F1510 means_sample_variance, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1510a; do x=1 to 11; output; end; run;
proc means data=f1510a noprint; var x; output out=f1510o var=actual; run;

data _null_; if 0 then set f1510o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1510 rows=' rows;
else do; set f1510o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND4_PASS=F1510';
else put 'ERROR: ROUND4_FAIL=F1510 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1510:; quit;
