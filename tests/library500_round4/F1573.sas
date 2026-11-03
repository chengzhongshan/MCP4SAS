/* F1573 means_squared_range, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1573a; do x=1 to 4; y=x*x; output; end; run;
proc means data=f1573a noprint; var y; output out=f1573o range=actual; run;

data _null_; if 0 then set f1573o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1573 rows=' rows;
else do; set f1573o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND4_PASS=F1573';
else put 'ERROR: ROUND4_FAIL=F1573 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1573:; quit;
