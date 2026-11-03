/* J3873 sql_having_unselected_aggregate, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data j3873a; do grp=1 to 2; do j=1 to 4; x=grp; output; end; end; run;
proc sql; create table j3873b as select grp from j3873a group by grp having sum(x)>4;
create table j3873o as select sum(grp) as actual from j3873b; quit;

data _null_; if 0 then set j3873o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3873 rows=' rows;
else do; set j3873o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3873';
else put 'ERROR: ROUND8_FAIL=J3873 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3873:; quit;
