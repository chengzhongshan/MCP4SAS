/* F1621 univariate_interquartile_range, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1621a; do x=1 to 4*2; output; end; run;
proc univariate data=f1621a noprint; var x; output out=f1621o qrange=actual; run;

data _null_; if 0 then set f1621o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1621 rows=' rows;
else do; set f1621o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1621';
else put 'ERROR: ROUND4_FAIL=F1621 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1621:; quit;
