/* B3165 means_autoname_columns, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3165a; do x=1 to 6; y=2*x; output; end; run;
proc means data=b3165a noprint; var x y; output out=b3165b mean= / autoname; run;
data b3165o; set b3165b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3165o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3165 rows=' rows;
else do; set b3165o; if not missing(actual) and abs(actual-(10.5))<=1e-9*max(1,abs(10.5)) then put 'ROUND7_PASS=B3165';
else put 'ERROR: ROUND7_FAIL=B3165 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3165:; quit;
