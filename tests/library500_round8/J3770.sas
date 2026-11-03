/* J3770 set_indsname_origin, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:775 */

data j3770a; x=11; run; data j3770b; x=12; run;
data j3770c; set j3770a j3770b indsname=origin; flag=(upcase(origin)=upcase("WORK.j3770b")); run;
proc sql; create table j3770o as select sum(flag*x) as actual from j3770c; quit;

data _null_; if 0 then set j3770o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3770 rows=' rows;
else do; set j3770o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND8_PASS=J3770';
else put 'ERROR: ROUND8_FAIL=J3770 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3770:; quit;
