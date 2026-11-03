/* J3724 name_literal_datastep, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3724saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3724o; 'patient age'n=5; actual='patient age'n+1; run;
options &j3724saved;
%symdel j3724saved;

data _null_; if 0 then set j3724o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3724 rows=' rows;
else do; set j3724o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3724';
else put 'ERROR: ROUND8_FAIL=J3724 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3724:; quit;
