/* J3736 name_literal_sql, N=7; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3736saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3736a; do 'visit day'n=1 to 7; output; end; run;
proc sql; create table j3736o as select sum('visit day'n) as actual from j3736a; quit;
options &j3736saved;
%symdel j3736saved;

data _null_; if 0 then set j3736o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3736 rows=' rows;
else do; set j3736o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND8_PASS=J3736';
else put 'ERROR: ROUND8_FAIL=J3736 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3736:; quit;
