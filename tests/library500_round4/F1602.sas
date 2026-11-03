/* F1602 univariate_odd_median, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1602a; do x=1 to 2*3+1; output; end; run;
proc univariate data=f1602a noprint; var x; output out=f1602o median=actual; run;

data _null_; if 0 then set f1602o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1602 rows=' rows;
else do; set f1602o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1602';
else put 'ERROR: ROUND4_FAIL=F1602 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1602:; quit;
