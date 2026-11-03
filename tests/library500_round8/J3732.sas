/* J3732 name_literal_sql, N=3; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3732saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3732a; do 'visit day'n=1 to 3; output; end; run;
proc sql; create table j3732o as select sum('visit day'n) as actual from j3732a; quit;
options &j3732saved;
%symdel j3732saved;

data _null_; if 0 then set j3732o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3732 rows=' rows;
else do; set j3732o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3732';
else put 'ERROR: ROUND8_FAIL=J3732 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3732:; quit;
