/* B3088 delete_and_explicit_outputs, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3088a; do x=1 to 2*9; output; end; run;
data b3088b; set b3088a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3088o as select sum(x) as actual from b3088b; quit;

data _null_; if 0 then set b3088o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3088 rows=' rows;
else do; set b3088o; if not missing(actual) and abs(actual-(180))<=1e-9*max(1,abs(180)) then put 'ROUND7_PASS=B3088';
else put 'ERROR: ROUND7_FAIL=B3088 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3088:; quit;
