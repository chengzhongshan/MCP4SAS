/* B3433 sql_order_calculated, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:808 */

data b3433a; do x=1 to 4; output; end; run;
proc sql; create table b3433b as select x,x*x as square from b3433a order by calculated square desc; quit;
data b3433o; set b3433b; if _n_=1; actual=x; run;

data _null_; if 0 then set b3433o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3433 rows=' rows;
else do; set b3433o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND7_PASS=B3433';
else put 'ERROR: ROUND7_FAIL=B3433 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3433:; quit;
