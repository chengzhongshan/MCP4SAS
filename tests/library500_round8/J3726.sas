/* J3726 name_literal_datastep, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3726saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3726o; 'patient age'n=7; actual='patient age'n+1; run;
options &j3726saved;
%symdel j3726saved;

data _null_; if 0 then set j3726o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3726 rows=' rows;
else do; set j3726o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3726';
else put 'ERROR: ROUND8_FAIL=J3726 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3726:; quit;
