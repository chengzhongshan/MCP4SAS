/* B3164 means_autoname_columns, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3164a; do x=1 to 5; y=2*x; output; end; run;
proc means data=b3164a noprint; var x y; output out=b3164b mean= / autoname; run;
data b3164o; set b3164b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3164o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3164 rows=' rows;
else do; set b3164o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND7_PASS=B3164';
else put 'ERROR: ROUND7_FAIL=B3164 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3164:; quit;
