/* F1607 univariate_odd_median, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1607a; do x=1 to 2*8+1; output; end; run;
proc univariate data=f1607a noprint; var x; output out=f1607o median=actual; run;

data _null_; if 0 then set f1607o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1607 rows=' rows;
else do; set f1607o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND4_PASS=F1607';
else put 'ERROR: ROUND4_FAIL=F1607 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1607:; quit;
