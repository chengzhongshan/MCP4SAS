/* F1539 means_coefficient_variation, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1539a; do x=1 to 10; output; end; run;
proc means data=f1539a noprint; var x; output out=f1539o cv=actual; run;

data _null_; if 0 then set f1539o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1539 rows=' rows;
else do; set f1539o; if not missing(actual) and abs(actual-(55.048188256318))<=1e-9*max(1,abs(55.048188256318)) then put 'ROUND4_PASS=F1539';
else put 'ERROR: ROUND4_FAIL=F1539 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1539:; quit;
