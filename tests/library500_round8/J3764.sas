/* J3764 set_indsname_origin, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3764a; x=5; run; data j3764b; x=6; run;
data j3764c; set j3764a j3764b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3764b")); run;
proc sql; create table j3764o as select sum(flag*x) as actual from j3764c; quit;

data _null_; if 0 then set j3764o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3764 rows=' rows;
else do; set j3764o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3764';
else put 'ERROR: ROUND8_FAIL=J3764 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3764:; quit;
