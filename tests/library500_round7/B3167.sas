/* B3167 means_autoname_columns, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3167a; do x=1 to 8; y=2*x; output; end; run;
proc means data=b3167a noprint; var x y; output out=b3167b mean= / autoname; run;
data b3167o; set b3167b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3167o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3167 rows=' rows;
else do; set b3167o; if not missing(actual) and abs(actual-(13.5))<=1e-9*max(1,abs(13.5)) then put 'ROUND7_PASS=B3167';
else put 'ERROR: ROUND7_FAIL=B3167 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3167:; quit;
