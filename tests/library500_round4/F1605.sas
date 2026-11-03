/* F1605 univariate_odd_median, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1605a; do x=1 to 2*6+1; output; end; run;
proc univariate data=f1605a noprint; var x; output out=f1605o median=actual; run;

data _null_; if 0 then set f1605o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1605 rows=' rows;
else do; set f1605o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND4_PASS=F1605';
else put 'ERROR: ROUND4_FAIL=F1605 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1605:; quit;
