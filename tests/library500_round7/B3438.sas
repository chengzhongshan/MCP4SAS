/* B3438 sql_order_calculated, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:808 */

data b3438a; do x=1 to 9; output; end; run;
proc sql; create table b3438b as select x,x*x as square from b3438a order by calculated square desc; quit;
data b3438o; set b3438b; if _n_=1; actual=x; run;

data _null_; if 0 then set b3438o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3438 rows=' rows;
else do; set b3438o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND7_PASS=B3438';
else put 'ERROR: ROUND7_FAIL=B3438 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3438:; quit;
