/* J3861 sql_scalar_subquery_sum, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3861a; x=2; run; data j3861b; do y=1 to 2; output; end; run;
proc sql; create table j3861o as select x+(select sum(y) from j3861b) as actual from j3861a; quit;

data _null_; if 0 then set j3861o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3861 rows=' rows;
else do; set j3861o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3861';
else put 'ERROR: ROUND8_FAIL=J3861 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3861:; quit;
