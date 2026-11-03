/* J3854 sql_except_all_multiplicity, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1010 */

data j3854a; do j=1 to 5+2; x=1; output; end; run;
data j3854b; do j=1 to 5; x=1; output; end; run;
proc sql; create table j3854c as select x from j3854a except all select x from j3854b;
create table j3854o as select count(*) as actual from j3854c; quit;

data _null_; if 0 then set j3854o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3854 rows=' rows;
else do; set j3854o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3854';
else put 'ERROR: ROUND8_FAIL=J3854 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3854:; quit;
