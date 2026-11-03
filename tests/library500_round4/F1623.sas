/* F1623 univariate_interquartile_range, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1623a; do x=1 to 4*4; output; end; run;
proc univariate data=f1623a noprint; var x; output out=f1623o qrange=actual; run;

data _null_; if 0 then set f1623o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1623 rows=' rows;
else do; set f1623o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND4_PASS=F1623';
else put 'ERROR: ROUND4_FAIL=F1623 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1623:; quit;
