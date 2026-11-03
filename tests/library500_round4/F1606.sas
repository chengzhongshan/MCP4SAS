/* F1606 univariate_odd_median, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1606a; do x=1 to 2*7+1; output; end; run;
proc univariate data=f1606a noprint; var x; output out=f1606o median=actual; run;

data _null_; if 0 then set f1606o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1606 rows=' rows;
else do; set f1606o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND4_PASS=F1606';
else put 'ERROR: ROUND4_FAIL=F1606 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1606:; quit;
