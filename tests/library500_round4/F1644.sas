/* F1644 univariate_uniform_kurtosis, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1644a; do x=1 to 5+3; output; end; run;
proc univariate data=f1644a noprint; var x; output out=f1644o kurtosis=actual; run;

data _null_; if 0 then set f1644o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1644 rows=' rows;
else do; set f1644o; if not missing(actual) and abs(actual-(-1.2))<=1e-9*max(1,abs(-1.2)) then put 'ROUND4_PASS=F1644';
else put 'ERROR: ROUND4_FAIL=F1644 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1644:; quit;
