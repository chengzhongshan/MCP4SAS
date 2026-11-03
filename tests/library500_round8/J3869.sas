/* J3869 sql_scalar_subquery_sum, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3869a; x=10; run; data j3869b; do y=1 to 10; output; end; run;
proc sql; create table j3869o as select x+(select sum(y) from j3869b) as actual from j3869a; quit;

data _null_; if 0 then set j3869o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3869 rows=' rows;
else do; set j3869o; if not missing(actual) and abs(actual-(65))<=1e-9*max(1,abs(65)) then put 'ROUND8_PASS=J3869';
else put 'ERROR: ROUND8_FAIL=J3869 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3869:; quit;
