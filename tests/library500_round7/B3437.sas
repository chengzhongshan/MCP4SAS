/* B3437 sql_order_calculated, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:808 */

data b3437a; do x=1 to 8; output; end; run;
proc sql; create table b3437b as select x,x*x as square from b3437a order by calculated square desc; quit;
data b3437o; set b3437b; if _n_=1; actual=x; run;

data _null_; if 0 then set b3437o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3437 rows=' rows;
else do; set b3437o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND7_PASS=B3437';
else put 'ERROR: ROUND7_FAIL=B3437 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3437:; quit;
