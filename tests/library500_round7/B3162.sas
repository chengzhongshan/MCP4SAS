/* B3162 means_autoname_columns, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data b3162a; do x=1 to 3; y=2*x; output; end; run;
proc means data=b3162a noprint; var x y; output out=b3162b mean= / autoname; run;
data b3162o; set b3162b; actual=x_mean+y_mean; run;

data _null_; if 0 then set b3162o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3162 rows=' rows;
else do; set b3162o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3162';
else put 'ERROR: ROUND7_FAIL=B3162 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3162:; quit;
