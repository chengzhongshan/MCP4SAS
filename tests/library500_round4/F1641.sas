/* F1641 univariate_uniform_kurtosis, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1641a; do x=1 to 2+3; output; end; run;
proc univariate data=f1641a noprint; var x; output out=f1641o kurtosis=actual; run;

data _null_; if 0 then set f1641o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1641 rows=' rows;
else do; set f1641o; if not missing(actual) and abs(actual-(-1.2))<=1e-9*max(1,abs(-1.2)) then put 'ROUND4_PASS=F1641';
else put 'ERROR: ROUND4_FAIL=F1641 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1641:; quit;
