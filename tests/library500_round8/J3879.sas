/* J3879 sql_having_unselected_aggregate, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:930 */

data j3879a; do grp=1 to 2; do j=1 to 10; x=grp; output; end; end; run;
proc sql; create table j3879b as select grp from j3879a group by grp having sum(x)>10;
create table j3879o as select sum(grp) as actual from j3879b; quit;

data _null_; if 0 then set j3879o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3879 rows=' rows;
else do; set j3879o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3879';
else put 'ERROR: ROUND8_FAIL=J3879 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3879:; quit;
