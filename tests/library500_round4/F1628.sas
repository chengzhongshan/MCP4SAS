/* F1628 univariate_interquartile_range, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1628a; do x=1 to 4*9; output; end; run;
proc univariate data=f1628a noprint; var x; output out=f1628o qrange=actual; run;

data _null_; if 0 then set f1628o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1628 rows=' rows;
else do; set f1628o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND4_PASS=F1628';
else put 'ERROR: ROUND4_FAIL=F1628 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1628:; quit;
