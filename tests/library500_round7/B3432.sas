/* B3432 sql_order_calculated, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:808 */

data b3432a; do x=1 to 3; output; end; run;
proc sql; create table b3432b as select x,x*x as square from b3432a order by calculated square desc; quit;
data b3432o; set b3432b; if _n_=1; actual=x; run;

data _null_; if 0 then set b3432o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3432 rows=' rows;
else do; set b3432o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND7_PASS=B3432';
else put 'ERROR: ROUND7_FAIL=B3432 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3432:; quit;
