/* B3084 delete_and_explicit_outputs, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3084a; do x=1 to 2*5; output; end; run;
data b3084b; set b3084a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3084o as select sum(x) as actual from b3084b; quit;

data _null_; if 0 then set b3084o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3084 rows=' rows;
else do; set b3084o; if not missing(actual) and abs(actual-(60))<=1e-9*max(1,abs(60)) then put 'ROUND7_PASS=B3084';
else put 'ERROR: ROUND7_FAIL=B3084 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3084:; quit;
