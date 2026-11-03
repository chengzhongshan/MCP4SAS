/* J3875 sql_having_unselected_aggregate, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data j3875a; do grp=1 to 2; do j=1 to 6; x=grp; output; end; end; run;
proc sql; create table j3875b as select grp from j3875a group by grp having sum(x)>6;
create table j3875o as select sum(grp) as actual from j3875b; quit;

data _null_; if 0 then set j3875o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3875 rows=' rows;
else do; set j3875o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3875';
else put 'ERROR: ROUND8_FAIL=J3875 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3875:; quit;
