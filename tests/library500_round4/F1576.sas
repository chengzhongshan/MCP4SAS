/* F1576 means_squared_range, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1576a; do x=1 to 7; y=x*x; output; end; run;
proc means data=f1576a noprint; var y; output out=f1576o range=actual; run;

data _null_; if 0 then set f1576o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1576 rows=' rows;
else do; set f1576o; if not missing(actual) and abs(actual-(48))<=1e-9*max(1,abs(48)) then put 'ROUND4_PASS=F1576';
else put 'ERROR: ROUND4_FAIL=F1576 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1576:; quit;
