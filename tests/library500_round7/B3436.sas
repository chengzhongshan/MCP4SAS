/* B3436 sql_order_calculated, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:808 */

data b3436a; do x=1 to 7; output; end; run;
proc sql; create table b3436b as select x,x*x as square from b3436a order by calculated square desc; quit;
data b3436o; set b3436b; if _n_=1; actual=x; run;

data _null_; if 0 then set b3436o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3436 rows=' rows;
else do; set b3436o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND7_PASS=B3436';
else put 'ERROR: ROUND7_FAIL=B3436 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3436:; quit;
