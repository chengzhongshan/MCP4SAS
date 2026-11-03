/* J3877 sql_having_unselected_aggregate, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data j3877a; do grp=1 to 2; do j=1 to 8; x=grp; output; end; end; run;
proc sql; create table j3877b as select grp from j3877a group by grp having sum(x)>8;
create table j3877o as select sum(grp) as actual from j3877b; quit;

data _null_; if 0 then set j3877o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3877 rows=' rows;
else do; set j3877o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3877';
else put 'ERROR: ROUND8_FAIL=J3877 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3877:; quit;
