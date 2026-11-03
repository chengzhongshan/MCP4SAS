/* B3081 delete_and_explicit_outputs, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:299 */

data b3081a; do x=1 to 2*2; output; end; run;
data b3081b; set b3081a; if mod(x,2)=1 then delete; output; output; run;
proc sql; create table b3081o as select sum(x) as actual from b3081b; quit;

data _null_; if 0 then set b3081o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3081 rows=' rows;
else do; set b3081o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3081';
else put 'ERROR: ROUND7_FAIL=B3081 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3081:; quit;
