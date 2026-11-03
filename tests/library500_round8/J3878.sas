/* J3878 sql_having_unselected_aggregate, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data j3878a; do grp=1 to 2; do j=1 to 9; x=grp; output; end; end; run;
proc sql; create table j3878b as select grp from j3878a group by grp having sum(x)>9;
create table j3878o as select sum(grp) as actual from j3878b; quit;

data _null_; if 0 then set j3878o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3878 rows=' rows;
else do; set j3878o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3878';
else put 'ERROR: ROUND8_FAIL=J3878 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3878:; quit;
