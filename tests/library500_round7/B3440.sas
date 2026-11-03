/* B3440 sql_order_calculated, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:808 */

data b3440a; do x=1 to 11; output; end; run;
proc sql; create table b3440b as select x,x*x as square from b3440a order by calculated square desc; quit;
data b3440o; set b3440b; if _n_=1; actual=x; run;

data _null_; if 0 then set b3440o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3440 rows=' rows;
else do; set b3440o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND7_PASS=B3440';
else put 'ERROR: ROUND7_FAIL=B3440 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3440:; quit;
