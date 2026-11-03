/* J3721 name_literal_datastep, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

%let j3721saved=%sysfunc(getoption(validvarname,keyword));
options validvarname=any;
data j3721o; 'patient age'n=2; actual='patient age'n+1; run;
options &j3721saved;
%symdel j3721saved;

data _null_; if 0 then set j3721o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3721 rows=' rows;
else do; set j3721o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3721';
else put 'ERROR: ROUND8_FAIL=J3721 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3721:; quit;
