/* J3727 name_literal_datastep, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3727saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3727o; 'patient age'n=8; actual='patient age'n+1; run;
options &j3727saved;
%symdel j3727saved;

data _null_; if 0 then set j3727o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3727 rows=' rows;
else do; set j3727o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3727';
else put 'ERROR: ROUND8_FAIL=J3727 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3727:; quit;
