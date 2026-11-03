/* J3872 sql_having_unselected_aggregate, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data j3872a; do grp=1 to 2; do j=1 to 3; x=grp; output; end; end; run;
proc sql; create table j3872b as select grp from j3872a group by grp having sum(x)>3;
create table j3872o as select sum(grp) as actual from j3872b; quit;

data _null_; if 0 then set j3872o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3872 rows=' rows;
else do; set j3872o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3872';
else put 'ERROR: ROUND8_FAIL=J3872 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3872:; quit;
