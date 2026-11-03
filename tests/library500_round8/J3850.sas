/* J3850 sql_intersect_all_multiplicity, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3850a; do j=1 to 11+2; x=1; output; end; run;
data j3850b; do j=1 to 11; x=1; output; end; run;
proc sql; create table j3850c as select x from j3850a intersect all select x from j3850b;
create table j3850o as select count(*) as actual from j3850c; quit;

data _null_; if 0 then set j3850o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3850 rows=' rows;
else do; set j3850o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3850';
else put 'ERROR: ROUND8_FAIL=J3850 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3850:; quit;
