/* J3738 name_literal_sql, N=9; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3738saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3738a; do 'visit day'n=1 to 9; output; end; run;
proc sql; create table j3738o as select sum('visit day'n) as actual from j3738a; quit;
options &j3738saved;
%symdel j3738saved;

data _null_; if 0 then set j3738o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3738 rows=' rows;
else do; set j3738o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND8_PASS=J3738';
else put 'ERROR: ROUND8_FAIL=J3738 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3738:; quit;
