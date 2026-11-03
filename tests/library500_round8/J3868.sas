/* J3868 sql_scalar_subquery_sum, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3868a; x=9; run; data j3868b; do y=1 to 9; output; end; run;
proc sql; create table j3868o as select x+(select sum(y) from j3868b) as actual from j3868a; quit;

data _null_; if 0 then set j3868o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3868 rows=' rows;
else do; set j3868o; if not missing(actual) and abs(actual-(54))<=1e-9*max(1,abs(54)) then put 'ROUND8_PASS=J3868';
else put 'ERROR: ROUND8_FAIL=J3868 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3868:; quit;
