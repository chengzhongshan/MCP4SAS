/* J3837 sql_union_corresponding_columns, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3837a; x=8; y=100; run;
data j3837b; y=200; x=9; run;
proc sql; create table j3837c as select x,y from j3837a union corr select y,x from j3837b;
create table j3837o as select sum(x) as actual from j3837c; quit;

data _null_; if 0 then set j3837o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3837 rows=' rows;
else do; set j3837o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND8_PASS=J3837';
else put 'ERROR: ROUND8_FAIL=J3837 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3837:; quit;
