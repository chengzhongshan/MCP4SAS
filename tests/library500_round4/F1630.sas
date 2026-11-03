/* F1630 univariate_interquartile_range, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1630a; do x=1 to 4*11; output; end; run;
proc univariate data=f1630a noprint; var x; output out=f1630o qrange=actual; run;

data _null_; if 0 then set f1630o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1630 rows=' rows;
else do; set f1630o; if not missing(actual) and abs(actual-(22))<=1e-9*max(1,abs(22)) then put 'ROUND4_PASS=F1630';
else put 'ERROR: ROUND4_FAIL=F1630 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1630:; quit;
