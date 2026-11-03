/* J3762 set_indsname_origin, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3762a; x=3; run; data j3762b; x=4; run;
data j3762c; set j3762a j3762b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3762b")); run;
proc sql; create table j3762o as select sum(flag*x) as actual from j3762c; quit;

data _null_; if 0 then set j3762o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3762 rows=' rows;
else do; set j3762o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3762';
else put 'ERROR: ROUND8_FAIL=J3762 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3762:; quit;
