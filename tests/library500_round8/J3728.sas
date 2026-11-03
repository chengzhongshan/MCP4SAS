/* J3728 name_literal_datastep, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3728saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3728o; 'patient age'n=9; actual='patient age'n+1; run;
options &j3728saved;
%symdel j3728saved;

data _null_; if 0 then set j3728o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3728 rows=' rows;
else do; set j3728o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3728';
else put 'ERROR: ROUND8_FAIL=J3728 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3728:; quit;
