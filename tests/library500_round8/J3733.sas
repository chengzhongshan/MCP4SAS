/* J3733 name_literal_sql, N=4; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3733saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3733a; do 'visit day'n=1 to 4; output; end; run;
proc sql; create table j3733o as select sum('visit day'n) as actual from j3733a; quit;
options &j3733saved;
%symdel j3733saved;

data _null_; if 0 then set j3733o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3733 rows=' rows;
else do; set j3733o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3733';
else put 'ERROR: ROUND8_FAIL=J3733 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3733:; quit;
