/* F1649 univariate_uniform_kurtosis, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1649a; do x=1 to 10+3; output; end; run;
proc univariate data=f1649a noprint; var x; output out=f1649o kurtosis=actual; run;

data _null_; if 0 then set f1649o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1649 rows=' rows;
else do; set f1649o; if not missing(actual) and abs(actual-(-1.2))<=1e-9*max(1,abs(-1.2)) then put 'ROUND4_PASS=F1649';
else put 'ERROR: ROUND4_FAIL=F1649 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1649:; quit;
