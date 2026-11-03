/* J3763 set_indsname_origin, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3763a; x=4; run; data j3763b; x=5; run;
data j3763c; set j3763a j3763b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3763b")); run;
proc sql; create table j3763o as select sum(flag*x) as actual from j3763c; quit;

data _null_; if 0 then set j3763o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3763 rows=' rows;
else do; set j3763o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3763';
else put 'ERROR: ROUND8_FAIL=J3763 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3763:; quit;
