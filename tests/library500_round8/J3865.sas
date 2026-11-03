/* J3865 sql_scalar_subquery_sum, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3865a; x=6; run; data j3865b; do y=1 to 6; output; end; run;
proc sql; create table j3865o as select x+(select sum(y) from j3865b) as actual from j3865a; quit;

data _null_; if 0 then set j3865o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3865 rows=' rows;
else do; set j3865o; if not missing(actual) and abs(actual-(27))<=1e-9*max(1,abs(27)) then put 'ROUND8_PASS=J3865';
else put 'ERROR: ROUND8_FAIL=J3865 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3865:; quit;
