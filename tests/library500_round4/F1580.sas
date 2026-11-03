/* F1580 means_squared_range, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1580a; do x=1 to 11; y=x*x; output; end; run;
proc means data=f1580a noprint; var y; output out=f1580o range=actual; run;

data _null_; if 0 then set f1580o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1580 rows=' rows;
else do; set f1580o; if not missing(actual) and abs(actual-(120))<=1e-9*max(1,abs(120)) then put 'ROUND4_PASS=F1580';
else put 'ERROR: ROUND4_FAIL=F1580 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1580:; quit;
