/* J3722 name_literal_datastep, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3722saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3722o; 'patient age'n=3; actual='patient age'n+1; run;
options &j3722saved;
%symdel j3722saved;

data _null_; if 0 then set j3722o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3722 rows=' rows;
else do; set j3722o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3722';
else put 'ERROR: ROUND8_FAIL=J3722 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3722:; quit;
