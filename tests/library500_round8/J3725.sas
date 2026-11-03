/* J3725 name_literal_datastep, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3725saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3725o; 'patient age'n=6; actual='patient age'n+1; run;
options &j3725saved;
%symdel j3725saved;

data _null_; if 0 then set j3725o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3725 rows=' rows;
else do; set j3725o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3725';
else put 'ERROR: ROUND8_FAIL=J3725 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3725:; quit;
