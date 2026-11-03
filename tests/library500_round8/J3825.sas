/* J3825 sql_three_way_cross_join, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3825a; do x=1 to 6; output; end; run;
data j3825b; do y=1 to 2; output; end; run; data j3825c; do z=1 to 3; output; end; run;
proc sql; create table j3825o as select count(*) as actual from j3825a,j3825b,j3825c; quit;

data _null_; if 0 then set j3825o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3825 rows=' rows;
else do; set j3825o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND8_PASS=J3825';
else put 'ERROR: ROUND8_FAIL=J3825 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3825:; quit;
