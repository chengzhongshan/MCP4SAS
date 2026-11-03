/* J3740 name_literal_sql, N=11; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3740saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3740a; do 'visit day'n=1 to 11; output; end; run;
proc sql; create table j3740o as select sum('visit day'n) as actual from j3740a; quit;
options &j3740saved;
%symdel j3740saved;

data _null_; if 0 then set j3740o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3740 rows=' rows;
else do; set j3740o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND8_PASS=J3740';
else put 'ERROR: ROUND8_FAIL=J3740 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3740:; quit;
