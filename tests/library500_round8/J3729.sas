/* J3729 name_literal_datastep, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3729saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3729o; 'patient age'n=10; actual='patient age'n+1; run;
options &j3729saved;
%symdel j3729saved;

data _null_; if 0 then set j3729o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3729 rows=' rows;
else do; set j3729o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3729';
else put 'ERROR: ROUND8_FAIL=J3729 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3729:; quit;
