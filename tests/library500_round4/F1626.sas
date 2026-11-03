/* F1626 univariate_interquartile_range, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1626a; do x=1 to 4*7; output; end; run;
proc univariate data=f1626a noprint; var x; output out=f1626o qrange=actual; run;

data _null_; if 0 then set f1626o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1626 rows=' rows;
else do; set f1626o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND4_PASS=F1626';
else put 'ERROR: ROUND4_FAIL=F1626 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1626:; quit;
