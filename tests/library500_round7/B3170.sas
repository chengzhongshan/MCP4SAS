/* B3170 means_autoname_columns, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3170a; do x=1 to 11; y=2*x; output; end; run;
proc means data=b3170a noprint; var x y; output out=b3170b mean= / autoname; run;
data b3170o; set b3170b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3170o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3170 rows=' rows;
else do; set b3170o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND7_PASS=B3170';
else put 'ERROR: ROUND7_FAIL=B3170 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3170:; quit;
