/* F1579 means_squared_range, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1579a; do x=1 to 10; y=x*x; output; end; run;
proc means data=f1579a noprint; var y; output out=f1579o range=actual; run;

data _null_; if 0 then set f1579o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1579 rows=' rows;
else do; set f1579o; if not missing(actual) and abs(actual-(99))<=1e-9*max(1,abs(99)) then put 'ROUND4_PASS=F1579';
else put 'ERROR: ROUND4_FAIL=F1579 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1579:; quit;
