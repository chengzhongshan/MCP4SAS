/* J3874 sql_having_unselected_aggregate, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data j3874a; do grp=1 to 2; do j=1 to 5; x=grp; output; end; end; run;
proc sql; create table j3874b as select grp from j3874a group by grp having sum(x)>5;
create table j3874o as select sum(grp) as actual from j3874b; quit;

data _null_; if 0 then set j3874o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3874 rows=' rows;
else do; set j3874o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3874';
else put 'ERROR: ROUND8_FAIL=J3874 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3874:; quit;
