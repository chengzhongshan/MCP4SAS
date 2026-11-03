/* F1608 univariate_odd_median, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1608a; do x=1 to 2*9+1; output; end; run;
proc univariate data=f1608a noprint; var x; output out=f1608o median=actual; run;

data _null_; if 0 then set f1608o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1608 rows=' rows;
else do; set f1608o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1608';
else put 'ERROR: ROUND4_FAIL=F1608 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1608:; quit;
