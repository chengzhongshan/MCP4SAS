/* J3864 sql_scalar_subquery_sum, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3864a; x=5; run; data j3864b; do y=1 to 5; output; end; run;
proc sql; create table j3864o as select x+(select sum(y) from j3864b) as actual from j3864a; quit;

data _null_; if 0 then set j3864o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3864 rows=' rows;
else do; set j3864o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND8_PASS=J3864';
else put 'ERROR: ROUND8_FAIL=J3864 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3864:; quit;
