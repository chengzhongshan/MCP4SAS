/* F1501 means_sample_variance, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1501a; do x=1 to 2; output; end; run;
proc means data=f1501a noprint; var x; output out=f1501o var=actual; run;

data _null_; if 0 then set f1501o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1501 rows=' rows;
else do; set f1501o; if not missing(actual) and abs(actual-(0.5))<=1e-9*max(1,abs(0.5)) then put 'ROUND4_PASS=F1501';
else put 'ERROR: ROUND4_FAIL=F1501 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1501:; quit;
