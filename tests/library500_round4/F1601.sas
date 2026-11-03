/* F1601 univariate_odd_median, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1601a; do x=1 to 2*2+1; output; end; run;
proc univariate data=f1601a noprint; var x; output out=f1601o median=actual; run;

data _null_; if 0 then set f1601o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1601 rows=' rows;
else do; set f1601o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1601';
else put 'ERROR: ROUND4_FAIL=F1601 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1601:; quit;
