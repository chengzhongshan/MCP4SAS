/* J3730 name_literal_datastep, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3730saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3730o; 'patient age'n=11; actual='patient age'n+1; run;
options &j3730saved;
%symdel j3730saved;

data _null_; if 0 then set j3730o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3730 rows=' rows;
else do; set j3730o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND8_PASS=J3730';
else put 'ERROR: ROUND8_FAIL=J3730 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3730:; quit;
