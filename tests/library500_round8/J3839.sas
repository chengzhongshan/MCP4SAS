/* J3839 sql_union_corresponding_columns, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:1045 */

data j3839a; x=10; y=100; run;
data j3839b; y=200; x=11; run;
proc sql; create table j3839c as select x,y from j3839a union corr select y,x from j3839b;
create table j3839o as select sum(x) as actual from j3839c; quit;

data _null_; if 0 then set j3839o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3839 rows=' rows;
else do; set j3839o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND8_PASS=J3839';
else put 'ERROR: ROUND8_FAIL=J3839 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3839:; quit;
