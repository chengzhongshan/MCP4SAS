/* B3169 means_autoname_columns, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3169a; do x=1 to 10; y=2*x; output; end; run;
proc means data=b3169a noprint; var x y; output out=b3169b mean= / autoname; run;
data b3169o; set b3169b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3169o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3169 rows=' rows;
else do; set b3169o; if not missing(actual) and abs(actual-(16.5))<=1e-9*max(1,abs(16.5)) then put 'ROUND7_PASS=B3169';
else put 'ERROR: ROUND7_FAIL=B3169 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3169:; quit;
