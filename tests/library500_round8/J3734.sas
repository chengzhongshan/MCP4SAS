/* J3734 name_literal_sql, N=5; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3734saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3734a; do 'visit day'n=1 to 5; output; end; run;
proc sql; create table j3734o as select sum('visit day'n) as actual from j3734a; quit;
options &j3734saved;
%symdel j3734saved;

data _null_; if 0 then set j3734o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3734 rows=' rows;
else do; set j3734o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND8_PASS=J3734';
else put 'ERROR: ROUND8_FAIL=J3734 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3734:; quit;
