/* F1578 means_squared_range, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1578a; do x=1 to 9; y=x*x; output; end; run;
proc means data=f1578a noprint; var y; output out=f1578o range=actual; run;

data _null_; if 0 then set f1578o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1578 rows=' rows;
else do; set f1578o; if not missing(actual) and abs(actual-(80))<=1e-9*max(1,abs(80)) then put 'ROUND4_PASS=F1578';
else put 'ERROR: ROUND4_FAIL=F1578 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1578:; quit;
