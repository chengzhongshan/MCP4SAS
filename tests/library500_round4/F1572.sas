/* F1572 means_squared_range, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1572a; do x=1 to 3; y=x*x; output; end; run;
proc means data=f1572a noprint; var y; output out=f1572o range=actual; run;

data _null_; if 0 then set f1572o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1572 rows=' rows;
else do; set f1572o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND4_PASS=F1572';
else put 'ERROR: ROUND4_FAIL=F1572 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1572:; quit;
