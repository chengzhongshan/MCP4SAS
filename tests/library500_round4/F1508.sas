/* F1508 means_sample_variance, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1508a; do x=1 to 9; output; end; run;
proc means data=f1508a noprint; var x; output out=f1508o var=actual; run;

data _null_; if 0 then set f1508o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1508 rows=' rows;
else do; set f1508o; if not missing(actual) and abs(actual-(7.5))<=1e-9*max(1,abs(7.5)) then put 'ROUND4_PASS=F1508';
else put 'ERROR: ROUND4_FAIL=F1508 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1508:; quit;
