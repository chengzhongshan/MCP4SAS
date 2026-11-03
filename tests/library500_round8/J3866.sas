/* J3866 sql_scalar_subquery_sum, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3866a; x=7; run; data j3866b; do y=1 to 7; output; end; run;
proc sql; create table j3866o as select x+(select sum(y) from j3866b) as actual from j3866a; quit;

data _null_; if 0 then set j3866o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3866 rows=' rows;
else do; set j3866o; if not missing(actual) and abs(actual-(35))<=1e-9*max(1,abs(35)) then put 'ROUND8_PASS=J3866';
else put 'ERROR: ROUND8_FAIL=J3866 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3866:; quit;
