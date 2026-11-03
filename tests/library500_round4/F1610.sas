/* F1610 univariate_odd_median, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1610a; do x=1 to 2*11+1; output; end; run;
proc univariate data=f1610a noprint; var x; output out=f1610o median=actual; run;

data _null_; if 0 then set f1610o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1610 rows=' rows;
else do; set f1610o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND4_PASS=F1610';
else put 'ERROR: ROUND4_FAIL=F1610 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1610:; quit;
