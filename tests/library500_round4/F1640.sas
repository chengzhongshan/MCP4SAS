/* F1640 univariate_symmetric_skewness, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1640a; do x=1 to 2*11+1; output; end; run;
proc univariate data=f1640a noprint; var x; output out=f1640o skewness=actual; run;

data _null_; if 0 then set f1640o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1640 rows=' rows;
else do; set f1640o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1640';
else put 'ERROR: ROUND4_FAIL=F1640 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1640:; quit;
