/* B3439 sql_order_calculated, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:808 */

data b3439a; do x=1 to 10; output; end; run;
proc sql; create table b3439b as select x,x*x as square from b3439a order by calculated square desc; quit;
data b3439o; set b3439b; if _n_=1; actual=x; run;

data _null_; if 0 then set b3439o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3439 rows=' rows;
else do; set b3439o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND7_PASS=B3439';
else put 'ERROR: ROUND7_FAIL=B3439 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3439:; quit;
