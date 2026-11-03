/* J3735 name_literal_sql, N=6; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3735saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3735a; do 'visit day'n=1 to 6; output; end; run;
proc sql; create table j3735o as select sum('visit day'n) as actual from j3735a; quit;
options &j3735saved;
%symdel j3735saved;

data _null_; if 0 then set j3735o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3735 rows=' rows;
else do; set j3735o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND8_PASS=J3735';
else put 'ERROR: ROUND8_FAIL=J3735 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3735:; quit;
