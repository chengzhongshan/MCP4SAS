/* F1625 univariate_interquartile_range, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1625a; do x=1 to 4*6; output; end; run;
proc univariate data=f1625a noprint; var x; output out=f1625o qrange=actual; run;

data _null_; if 0 then set f1625o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1625 rows=' rows;
else do; set f1625o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND4_PASS=F1625';
else put 'ERROR: ROUND4_FAIL=F1625 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1625:; quit;
