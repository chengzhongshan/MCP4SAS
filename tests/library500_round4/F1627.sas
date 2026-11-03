/* F1627 univariate_interquartile_range, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/change y axis label in proc univariate for histogram.sas:1 */

data f1627a; do x=1 to 4*8; output; end; run;
proc univariate data=f1627a noprint; var x; output out=f1627o qrange=actual; run;

data _null_; if 0 then set f1627o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1627 rows=' rows;
else do; set f1627o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND4_PASS=F1627';
else put 'ERROR: ROUND4_FAIL=F1627 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1627:; quit;
