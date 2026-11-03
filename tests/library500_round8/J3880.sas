/* J3880 sql_having_unselected_aggregate, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data j3880a; do grp=1 to 2; do j=1 to 11; x=grp; output; end; end; run;
proc sql; create table j3880b as select grp from j3880a group by grp having sum(x)>11;
create table j3880o as select sum(grp) as actual from j3880b; quit;

data _null_; if 0 then set j3880o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3880 rows=' rows;
else do; set j3880o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3880';
else put 'ERROR: ROUND8_FAIL=J3880 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3880:; quit;
