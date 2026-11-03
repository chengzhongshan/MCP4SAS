/* F1624 univariate_interquartile_range, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1624a; do x=1 to 4*5; output; end; run;
proc univariate data=f1624a noprint; var x; output out=f1624o qrange=actual; run;

data _null_; if 0 then set f1624o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1624 rows=' rows;
else do; set f1624o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1624';
else put 'ERROR: ROUND4_FAIL=F1624 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1624:; quit;
