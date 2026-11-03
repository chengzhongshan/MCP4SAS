/* J3867 sql_scalar_subquery_sum, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3867a; x=8; run; data j3867b; do y=1 to 8; output; end; run;
proc sql; create table j3867o as select x+(select sum(y) from j3867b) as actual from j3867a; quit;

data _null_; if 0 then set j3867o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3867 rows=' rows;
else do; set j3867o; if not missing(actual) and abs(actual-(44))<=1e-9*max(1,abs(44)) then put 'ROUND8_PASS=J3867';
else put 'ERROR: ROUND8_FAIL=J3867 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3867:; quit;
