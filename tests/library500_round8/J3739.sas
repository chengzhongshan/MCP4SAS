/* J3739 name_literal_sql, N=10; source: Getting Started with the SQL Procedure, Version 6, First Edition.txt:73 */

%let j3739saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3739a; do 'visit day'n=1 to 10; output; end; run;
proc sql; create table j3739o as select sum('visit day'n) as actual from j3739a; quit;
options &j3739saved;
%symdel j3739saved;

data _null_; if 0 then set j3739o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3739 rows=' rows;
else do; set j3739o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND8_PASS=J3739';
else put 'ERROR: ROUND8_FAIL=J3739 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3739:; quit;
