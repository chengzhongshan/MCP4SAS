/* J3862 sql_scalar_subquery_sum, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3862a; x=3; run; data j3862b; do y=1 to 3; output; end; run;
proc sql; create table j3862o as select x+(select sum(y) from j3862b) as actual from j3862a; quit;

data _null_; if 0 then set j3862o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3862 rows=' rows;
else do; set j3862o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3862';
else put 'ERROR: ROUND8_FAIL=J3862 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3862:; quit;
