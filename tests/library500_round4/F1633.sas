/* F1633 univariate_symmetric_skewness, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1633a; do x=1 to 2*4+1; output; end; run;
proc univariate data=f1633a noprint; var x; output out=f1633o skewness=actual; run;

data _null_; if 0 then set f1633o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1633 rows=' rows;
else do; set f1633o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND4_PASS=F1633';
else put 'ERROR: ROUND4_FAIL=F1633 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1633:; quit;
