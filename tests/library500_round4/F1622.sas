/* F1622 univariate_interquartile_range, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1622a; do x=1 to 4*3; output; end; run;
proc univariate data=f1622a noprint; var x; output out=f1622o qrange=actual; run;

data _null_; if 0 then set f1622o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1622 rows=' rows;
else do; set f1622o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1622';
else put 'ERROR: ROUND4_FAIL=F1622 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1622:; quit;
