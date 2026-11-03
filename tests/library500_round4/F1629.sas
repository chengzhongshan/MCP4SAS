/* F1629 univariate_interquartile_range, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1629a; do x=1 to 4*10; output; end; run;
proc univariate data=f1629a noprint; var x; output out=f1629o qrange=actual; run;

data _null_; if 0 then set f1629o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1629 rows=' rows;
else do; set f1629o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND4_PASS=F1629';
else put 'ERROR: ROUND4_FAIL=F1629 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1629:; quit;
