/* B3161 means_autoname_columns, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3161a; do x=1 to 2; y=2*x; output; end; run;
proc means data=b3161a noprint; var x y; output out=b3161b mean= / autoname; run;
data b3161o; set b3161b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3161o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3161 rows=' rows;
else do; set b3161o; if not missing(actual) and abs(actual-(4.5))<=1e-9*max(1,abs(4.5)) then put 'ROUND7_PASS=B3161';
else put 'ERROR: ROUND7_FAIL=B3161 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3161:; quit;
