/* B3166 means_autoname_columns, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3166a; do x=1 to 7; y=2*x; output; end; run;
proc means data=b3166a noprint; var x y; output out=b3166b mean= / autoname; run;
data b3166o; set b3166b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3166o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3166 rows=' rows;
else do; set b3166o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3166';
else put 'ERROR: ROUND7_FAIL=B3166 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3166:; quit;
