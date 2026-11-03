/* J3737 name_literal_sql, N=8; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3737saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3737a; do 'visit day'n=1 to 8; output; end; run;
proc sql; create table j3737o as select sum('visit day'n) as actual from j3737a; quit;
options &j3737saved;
%symdel j3737saved;

data _null_; if 0 then set j3737o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3737 rows=' rows;
else do; set j3737o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND8_PASS=J3737';
else put 'ERROR: ROUND8_FAIL=J3737 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3737:; quit;
