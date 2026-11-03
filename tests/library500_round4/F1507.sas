/* F1507 means_sample_variance, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1507a; do x=1 to 8; output; end; run;
proc means data=f1507a noprint; var x; output out=f1507o var=actual; run;

data _null_; if 0 then set f1507o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1507 rows=' rows;
else do; set f1507o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1507';
else put 'ERROR: ROUND4_FAIL=F1507 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1507:; quit;
