/* J3823 sql_three_way_cross_join, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

data j3823a; do x=1 to 4; output; end; run;
data j3823b; do y=1 to 2; output; end; run; data j3823c; do z=1 to 3; output; end; run;
proc sql; create table j3823o as select count(*) as actual from j3823a,j3823b,j3823c; quit;

data _null_; if 0 then set j3823o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3823 rows=' rows;
else do; set j3823o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND8_PASS=J3823';
else put 'ERROR: ROUND8_FAIL=J3823 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3823:; quit;
