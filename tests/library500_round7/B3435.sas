/* B3435 sql_order_calculated, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:808 */

data b3435a; do x=1 to 6; output; end; run;
proc sql; create table b3435b as select x,x*x as square from b3435a order by calculated square desc; quit;
data b3435o; set b3435b; if _n_=1; actual=x; run;

data _null_; if 0 then set b3435o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3435 rows=' rows;
else do; set b3435o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3435';
else put 'ERROR: ROUND7_FAIL=B3435 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3435:; quit;
