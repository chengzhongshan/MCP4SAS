/* J3769 set_indsname_origin, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3769a; x=10; run; data j3769b; x=11; run;
data j3769c; set j3769a j3769b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3769b")); run;
proc sql; create table j3769o as select sum(flag*x) as actual from j3769c; quit;

data _null_; if 0 then set j3769o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3769 rows=' rows;
else do; set j3769o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3769';
else put 'ERROR: ROUND8_FAIL=J3769 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3769:; quit;
