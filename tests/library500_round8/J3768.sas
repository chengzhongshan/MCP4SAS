/* J3768 set_indsname_origin, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3768a; x=9; run; data j3768b; x=10; run;
data j3768c; set j3768a j3768b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3768b")); run;
proc sql; create table j3768o as select sum(flag*x) as actual from j3768c; quit;

data _null_; if 0 then set j3768o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3768 rows=' rows;
else do; set j3768o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3768';
else put 'ERROR: ROUND8_FAIL=J3768 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3768:; quit;
