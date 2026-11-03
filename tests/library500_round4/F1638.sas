/* F1638 univariate_symmetric_skewness, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1638a; do x=1 to 2*9+1; output; end; run;
proc univariate data=f1638a noprint; var x; output out=f1638o skewness=actual; run;

data _null_; if 0 then set f1638o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1638 rows=' rows;
else do; set f1638o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1638';
else put 'ERROR: ROUND4_FAIL=F1638 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1638:; quit;
