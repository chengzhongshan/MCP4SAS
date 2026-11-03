/* F1536 means_coefficient_variation, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1536a; do x=1 to 7; output; end; run;
proc means data=f1536a noprint; var x; output out=f1536o cv=actual; run;

data _null_; if 0 then set f1536o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1536 rows=' rows;
else do; set f1536o; if not missing(actual) and abs(actual-(54.0061724867322))<=1e-9*max(1,abs(54.0061724867322)) then put 'ROUND4_PASS=F1536';
else put 'ERROR: ROUND4_FAIL=F1536 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1536:; quit;
