/* F1609 univariate_odd_median, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1609a; do x=1 to 2*10+1; output; end; run;
proc univariate data=f1609a noprint; var x; output out=f1609o median=actual; run;

data _null_; if 0 then set f1609o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1609 rows=' rows;
else do; set f1609o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND4_PASS=F1609';
else put 'ERROR: ROUND4_FAIL=F1609 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1609:; quit;
