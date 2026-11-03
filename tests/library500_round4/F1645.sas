/* F1645 univariate_uniform_kurtosis, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1645a; do x=1 to 6+3; output; end; run;
proc univariate data=f1645a noprint; var x; output out=f1645o kurtosis=actual; run;

data _null_; if 0 then set f1645o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1645 rows=' rows;
else do; set f1645o; if not missing(actual) and abs(actual-(-1.2))<=1e-9*max(1,abs(-1.2)) then put 'ROUND4_PASS=F1645';
else put 'ERROR: ROUND4_FAIL=F1645 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1645:; quit;
