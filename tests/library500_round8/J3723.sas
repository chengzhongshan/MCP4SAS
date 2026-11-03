/* J3723 name_literal_datastep, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3723saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3723o; 'patient age'n=4; actual='patient age'n+1; run;
options &j3723saved;
%symdel j3723saved;

data _null_; if 0 then set j3723o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3723 rows=' rows;
else do; set j3723o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3723';
else put 'ERROR: ROUND8_FAIL=J3723 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3723:; quit;
