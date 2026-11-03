/* J3835 sql_union_corresponding_columns, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3835a; x=6; y=100; run;
data j3835b; y=200; x=7; run;
proc sql; create table j3835c as select x,y from j3835a union corr select y,x from j3835b;
create table j3835o as select sum(x) as actual from j3835c; quit;

data _null_; if 0 then set j3835o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3835 rows=' rows;
else do; set j3835o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND8_PASS=J3835';
else put 'ERROR: ROUND8_FAIL=J3835 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3835:; quit;
