/* J3870 sql_scalar_subquery_sum, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3870a; x=11; run; data j3870b; do y=1 to 11; output; end; run;
proc sql; create table j3870o as select x+(select sum(y) from j3870b) as actual from j3870a; quit;

data _null_; if 0 then set j3870o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3870 rows=' rows;
else do; set j3870o; if not missing(actual) and abs(actual-(77))<=1e-9*max(1,abs(77)) then put 'ROUND8_PASS=J3870';
else put 'ERROR: ROUND8_FAIL=J3870 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3870:; quit;
