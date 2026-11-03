/* J3834 sql_union_corresponding_columns, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3834a; x=5; y=100; run;
data j3834b; y=200; x=6; run;
proc sql; create table j3834c as select x,y from j3834a union corr select y,x from j3834b;
create table j3834o as select sum(x) as actual from j3834c; quit;

data _null_; if 0 then set j3834o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3834 rows=' rows;
else do; set j3834o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3834';
else put 'ERROR: ROUND8_FAIL=J3834 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3834:; quit;
