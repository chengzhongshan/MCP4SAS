/* J3846 sql_intersect_all_multiplicity, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3846a; do j=1 to 7+2; x=1; output; end; run;
data j3846b; do j=1 to 7; x=1; output; end; run;
proc sql; create table j3846c as select x from j3846a intersect all select x from j3846b;
create table j3846o as select count(*) as actual from j3846c; quit;

data _null_; if 0 then set j3846o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3846 rows=' rows;
else do; set j3846o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3846';
else put 'ERROR: ROUND8_FAIL=J3846 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3846:; quit;
