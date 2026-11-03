/* F1571 means_squared_range, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1571a; do x=1 to 2; y=x*x; output; end; run;
proc means data=f1571a noprint; var y; output out=f1571o range=actual; run;

data _null_; if 0 then set f1571o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1571 rows=' rows;
else do; set f1571o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1571';
else put 'ERROR: ROUND4_FAIL=F1571 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1571:; quit;
