/* J3731 name_literal_sql, N=2; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3731saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3731a; do 'visit day'n=1 to 2; output; end; run;
proc sql; create table j3731o as select sum('visit day'n) as actual from j3731a; quit;
options &j3731saved;
%symdel j3731saved;

data _null_; if 0 then set j3731o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3731 rows=' rows;
else do; set j3731o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3731';
else put 'ERROR: ROUND8_FAIL=J3731 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3731:; quit;
