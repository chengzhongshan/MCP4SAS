/* J3871 sql_having_unselected_aggregate, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data j3871a; do grp=1 to 2; do j=1 to 2; x=grp; output; end; end; run;
proc sql; create table j3871b as select grp from j3871a group by grp having sum(x)>2;
create table j3871o as select sum(grp) as actual from j3871b; quit;

data _null_; if 0 then set j3871o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3871 rows=' rows;
else do; set j3871o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3871';
else put 'ERROR: ROUND8_FAIL=J3871 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3871:; quit;
