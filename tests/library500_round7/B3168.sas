/* B3168 means_autoname_columns, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3168a; do x=1 to 9; y=2*x; output; end; run;
proc means data=b3168a noprint; var x y; output out=b3168b mean= / autoname; run;
data b3168o; set b3168b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3168o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3168 rows=' rows;
else do; set b3168o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND7_PASS=B3168';
else put 'ERROR: ROUND7_FAIL=B3168 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3168:; quit;
