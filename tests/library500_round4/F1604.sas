/* F1604 univariate_odd_median, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1604a; do x=1 to 2*5+1; output; end; run;
proc univariate data=f1604a noprint; var x; output out=f1604o median=actual; run;

data _null_; if 0 then set f1604o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1604 rows=' rows;
else do; set f1604o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1604';
else put 'ERROR: ROUND4_FAIL=F1604 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1604:; quit;
