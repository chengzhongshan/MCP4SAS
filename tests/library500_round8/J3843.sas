/* J3843 sql_intersect_all_multiplicity, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:993 */

data j3843a; do j=1 to 4+2; x=1; output; end; run;
data j3843b; do j=1 to 4; x=1; output; end; run;
proc sql; create table j3843c as select x from j3843a intersect all select x from j3843b;
create table j3843o as select count(*) as actual from j3843c; quit;

data _null_; if 0 then set j3843o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3843 rows=' rows;
else do; set j3843o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3843';
else put 'ERROR: ROUND8_FAIL=J3843 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3843:; quit;
