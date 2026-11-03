/* F1503 means_sample_variance, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1503a; do x=1 to 4; output; end; run;
proc means data=f1503a noprint; var x; output out=f1503o var=actual; run;

data _null_; if 0 then set f1503o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1503 rows=' rows;
else do; set f1503o; if not missing(actual) and abs(actual-(1.66666666666667))<=1e-9*max(1,abs(1.66666666666667)) then put 'ROUND4_PASS=F1503';
else put 'ERROR: ROUND4_FAIL=F1503 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1503:; quit;
