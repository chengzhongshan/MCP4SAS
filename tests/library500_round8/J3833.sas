/* J3833 sql_union_corresponding_columns, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3833a; x=4; y=100; run;
data j3833b; y=200; x=5; run;
proc sql; create table j3833c as select x,y from j3833a union corr select y,x from j3833b;
create table j3833o as select sum(x) as actual from j3833c; quit;

data _null_; if 0 then set j3833o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3833 rows=' rows;
else do; set j3833o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3833';
else put 'ERROR: ROUND8_FAIL=J3833 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3833:; quit;
