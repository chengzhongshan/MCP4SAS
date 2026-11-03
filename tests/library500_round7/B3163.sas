/* B3163 means_autoname_columns, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3163a; do x=1 to 4; y=2*x; output; end; run;
proc means data=b3163a noprint; var x y; output out=b3163b mean= / autoname; run;
data b3163o; set b3163b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3163o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3163 rows=' rows;
else do; set b3163o; if not missing(actual) and abs(actual-(7.5))<=1e-9*max(1,abs(7.5)) then put 'ROUND7_PASS=B3163';
else put 'ERROR: ROUND7_FAIL=B3163 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3163:; quit;
